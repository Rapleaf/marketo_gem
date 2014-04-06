require 'forwardable'

# An object representing a Marketo Lead record.
class MarketoAPI::Lead
  extend Forwardable
  include Enumerable

  NAMED_KEYS = { #:nodoc:
    id:                         :IDNUM,
    cookie:                     :COOKIE,
    email:                      :EMAIL,
    lead_owner_email:           :LEADOWNEREMAIL,
    salesforce_account_id:      :SFDCACCOUNTID,
    salesforce_contact_id:      :SFDCCONTACTID,
    salesforce_lead_id:         :SFDCLEADID,
    salesforce_lead_owner_id:   :SFDCLEADOWNERID,
    salesforce_opportunity_id:  :SFDCOPPTYID
  }.freeze

  KEY_TYPES = MarketoAPI.freeze(*NAMED_KEYS.values) #:nodoc:
  private_constant :KEY_TYPES

  # The Marketo ID. This value cannot be set by consumers.
  attr_reader :id
  # The Marketo tracking cookie. Optional.
  attr_accessor :cookie

  # The attributes for the Lead.
  attr_reader :attributes
  # The types for the Lead attributes.
  attr_reader :types
  # The proxy object for this class.
  attr_reader :proxy

  def_delegators :@attributes, :[], :each, :each_pair, :each_key,
    :each_value, :keys, :values

  ##
  # :method: [](hash)
  # :call-seq:
  #   lead[attribute_key]
  #
  # Looks up the provided attribute.

  ##
  # :method: each
  # :call-seq:
  #   each { |key, value| block }
  #
  # Iterates over the attributes.

  ##
  # :method: each_pair
  # :call-seq:
  #   each_pair { |key, value| block }
  #
  # Iterates over the attributes.

  ##
  # :method: each_key
  # :call-seq:
  #   each_key { |key| block }
  #
  # Iterates over the attribute keys.

  ##
  # :method: each_value
  # :call-seq:
  #   each_value { |value| block }
  #
  # Iterates over the attribute values.

  ##
  # :method: keys
  # :call-seq:
  #   keys() -> array
  #
  # Returns the attribute keys.

  ##
  # :method: values
  # :call-seq:
  #   values() -> array
  #
  # Returns the attribute values.

  def initialize(options = {})
    @id          = options[:id]
    @attributes  = {}
    @types       = {}
    @foreign     = {}
    self[:Email] = options[:email]
    self.proxy   = options[:proxy]
    yield self if block_given?
  end

  ##
  # :method: []=(hash, value)
  # :call-seq:
  #   lead[key] = value -> value
  #
  # Looks up the provided attribute.
  def []=(key, value)
    @attributes[key] = value
    @types[key] ||= infer_value_type(value)
  end

  # :attr_writer:
  # :call-seq:
  #   lead.proxy = proxy -> proxy
  #
  # Assign a proxy object. Once set, the proxy cannot be unset, but it can be
  # changed.
  def proxy=(value)
    @proxy = case value
             when nil
               @proxy
             when MarketoAPI::Leads
               value
             when MarketoAPI::ClientProxy
               value.instance_variable_get(:@client).leads
             when MarketoAPI::Client
               value.leads
             else
               raise ArgumentError, "Invalid proxy type"
             end
  end

  # :call-seq:
  #   lead.foreign -> nil
  #   lead.foreign(type, id) -> { type: type, id: id }
  #   lead.foreign -> { type: type, id: id }
  #
  # Sets or returns the foreign system type and person ID.
  def foreign(type = nil, id = nil)
    @foreign = { type: type.to_sym, id: id } if type and id
    @foreign
  end

  # :attr_reader: email
  def email
    self[:Email]
  end

  # :attr_writer: email
  def email=(value)
    self[:Email] = value
  end

  # Performs a Lead sync and returns the new Lead object, or +nil+ if the
  # sync failed.
  #
  # Raises an ArgumentError if a proxy has not been configured with
  # Lead#proxy=.
  def sync
    raise ArgumentError, "No proxy configured" unless proxy
    proxy.sync(self)
  end

  # Performs a Lead sync and updates this Lead object in-place, or +nil+ if
  # the sync failed.
  #
  # Raises an ArgumentError if a proxy has not been configured with
  # Lead#proxy=.
  def sync!
    if lead = sync
      @id      = lead.id
      @cookie  = lead.cookie
      @foreign = lead.foreign
      @proxy   = lead.proxy
      removed  = self.keys - lead.keys

      lead.each_pair { |k, v|
        @attributes[k] = v
        @types[k]      = lead.types[k]
      }

      removed.each { |k|
        @attributes.delete(k)
        @types.delete(k)
      }
      self
    end
  end

  # Returns a lead key structure suitable for use with
  # MarketoAPI::Leads#get.
  def params_for_get
    self.class.key(:IDNUM, id)
  end

  # Returns the parameters required for use with MarketoAPI::Leads#sync.
  def params_for_sync
    {
      return_lead: true,
      market_cookie: cookie,
      lead_record: {
        email:                  email,
        id:                     id,
        foreign_sys_person_id:  foreign[:id],
        foreign_sys_type:       foreign[:type],
        lead_attribute_list: {
          attribute: attributes.map { |key, value|
            {
              attr_name:   key.to_s,
              attr_type:   types[key],
              attr_value:  value
            }
          }
        }
      }.delete_if(&MarketoAPI::MINIMIZE_HASH)
    }.delete_if(&MarketoAPI::MINIMIZE_HASH)
  end

  class << self
    # Creates a new Lead from a SOAP response hash (from Leads#get,
    # Leads#get_multiple, Leads#sync, or Leads#sync_multiple).
    def from_soap_hash(hash) #:nodoc:
      lead = new(id: hash[:id].to_i, email: hash[:email]) do |lr|
        if type = hash[:foreign_sys_type]
          lr.foreign(type, hash[:foreign_sys_person_id])
        end
        hash[:lead_attribute_list][:attribute].each do |attribute|
          name = attribute[:attr_name].to_sym
          lr.attributes[name] = attribute[:attr_value]
          lr.types[name] = attribute[:attr_type]
        end
      end
      yield lead if block_given?
      lead
    end

    # Creates a new Lead key hash suitable for use in a number of Marketo
    # API calls.
    def key(key, value)
      {
        lead_key: {
          key_type:   key_type(key),
          key_value:  value
        }
      }
    end

    private
    def key_type(key)
      res = if KEY_TYPES.include? key
               key
             else
               NAMED_KEYS[key]
             end
      raise ArgumentError, "Invalid key #{key}" unless res
      res
    end
  end

  def ==(other)
    id == other.id && cookie == other.cookie && foreign == other.foreign &&
      attributes == other.attributes && types == other.types
  end

  def inspect
    "#<#{self.class} id=#{id} cookie=#{cookie} foreign=#{foreign.inspect} attributes=#{attributes.inspect} types=#{types.inspect}>"
  end

  private
  def infer_value_type(value)
    case value
    when Integer
      'integer'
    when Time, DateTime
      'datetime'
    else
      'string'
    end
  end
end
