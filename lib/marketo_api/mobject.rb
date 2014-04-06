# A representation of Marketo object (MObject) records as well as key
# representations for getting, syncing, or deleting those records.
#
#
class MarketoAPI::MObject
  DELETE_TYPES = #:nodoc:
    MarketoAPI.freeze(:Opportunity, :OpportunityPersonRole)
  GET_TYPES    = #:nodoc:
    MarketoAPI.freeze(*DELETE_TYPES, :Program)
  ALL_TYPES    = #:nodoc:
    MarketoAPI.freeze(*GET_TYPES, :ActivityRecord, :LeadRecord)
  private_constant :DELETE_TYPES, :GET_TYPES, :ALL_TYPES

  # The type of Marketo object. Will be one of:
  #
  # - Opportunity
  # - OpportunityPersonRole
  # - Program
  # - ActivityRecord
  # - LeadRecord
  #
  # In general, only the first three can be interacted with through the SOAP
  # API.
  attr_reader   :type
  # The ID of the Marketo object.
  attr_accessor :id

  # When getting a Marketo Program, the details will be included if this is
  # true.
  attr_accessor :include_details
  # Associated objects.
  attr_reader   :associations
  # The stream position for paged queries.
  attr_accessor :stream_position

  # The detailed attributes of the Marketo object.
  attr_reader   :attributes
  # The detailed types of the Marketo object.
  attr_reader   :types

  def initialize(type, id = nil)
    ensure_valid_type!(type)
    @type       = type.to_sym
    @id         = id
    @attributes = {}
    @types      = Hash.new { |h, k| h[k] = {} }
    yield self if block_given?
  end

  # Adds query criteria for use with MarketoAPI::MObjects#get.
  #
  # === Name
  #
  # Name::                   Name of the MObject
  # Role::                   The role associated with an
  #                          OpportunityPersonRole object
  # Type::                   The type of an Opportunity object
  # Stage::                  The stage of an Opportunity object
  # CRM Id:                  The CRM ID could refer to the ID of the
  #                          Salesforce campaign connected to a Marketo
  #                          program
  # Created At::             The date the MObject was created. Can be used
  #                          with the comparisons EQ, NE, LT, LE, GT, and
  #                          GE. Two “created dates” can be specified to
  #                          create a date range.
  # Updated At or Tag Type:: (Only one can be specified) Can be used with
  #                          the comparisons EQ, NE, LT, LE, GT, and GE. Two
  #                          “updated dates” can be specified to create a
  #                          date range.
  # Tag Value:               (Only one can be specified)
  # Workspace Name:          (Only one can be specified)
  # Workspace Id:            (Only one can be specified)
  # Include Archive:         Applicable only with Program MObject. Set it to
  #                          true if you wish to include archived programs.
  #
  # === Comparison
  #
  # EQ:: Equals
  # NE:: Not Equals
  # LT:: Less Than
  # LE:: Less Than or Equals
  # GT:: Greater Than
  # GE:: Greater Than or Equals
  def criteria(name = nil, value = nil, comparison = nil)
    if name
      (@criteria ||= []) << {
        attr_name:   name,
        attr_value:  value,
        comparison:  comparison
      }
    end
    @criteria
  end

  # Add association criteria for use with MarketoAPI::MObjects#get or
  # MarketoAPI::MOBjects#sync (not yet implemented).
  #
  # The +type+ must be one of Lead, Company, or Opportunity. The +id+ is the
  # ID of the associated object, and the +external_key+ is an optional
  # custom attribute of the associated object.
  def association(type, id, external_key = nil)
    (@associations ||= []) << {
      m_obj_type:    type,
      id:            id,
      external_key:  external_key,
    }
  end

  def params_for_delete #:nodoc:
    ensure_valid_type!(type, DELETE_TYPES)
    raise ArgumentError, ":id cannot be nil" if id.nil?
    { type: type, id: id }
  end

  def params_for_get #:nodoc:
    ensure_valid_type!(type, GET_TYPES)
    {
      type:                    type,
      id:                      id,
      m_obj_criteria_list:     criteria,
      m_obj_association_list:  associations,
      stream_position:         stream_position
    }.delete_if(&MarketoAPI::MINIMIZE_HASH)
  end

  class << self
    # Creates a new MObject from a SOAP response hash (from MObjects#get or
    # MObjects#sync).
    def from_soap_hash(hash) #:nodoc:
      new(hash['type'], hash['id']) do |mobj|
        obj = hash['attrib_list']['attrib']
        MarketoAPI.array(obj).each do |attrib|
          mobj.attributes[attrib['name']] = attrib['value']
        end

        obj = hash['type_attrib_list']['type_attrib']
        MarketoAPI.array(obj).each do |type|
          MarketoAPI.array(type['attr_list']['attrib']).each do |attrib|
            mobj.types[type['attr_type']][attrib['name']] = attrib['value']
          end
        end
      end
    end

    ALL_TYPES.each do |type|
      define_method(type.downcase) do |id = nil, &block|
        new(type, id, &block)
      end
    end
  end

  private
  def ensure_valid_type!(type, list = ALL_TYPES)
    unless list.include? type.to_sym
      raise ArgumentError, ":type must be one of #{list.join(", ")}"
    end
  end
end
