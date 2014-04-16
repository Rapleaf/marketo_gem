# A representation of Marketo object (MObject) records as well as key
# representations for getting, syncing, or deleting those records.
class MarketoAPI::MObject
  DELETE_TYPES   = #:nodoc:
    MarketoAPI.freeze(:Opportunity, :OpportunityPersonRole)
  GET_TYPES      = #:nodoc:
    MarketoAPI.freeze(*DELETE_TYPES, :Program)
  DESCRIBE_TYPES = #:nodoc:
    MarketoAPI.freeze(*DELETE_TYPES, :ActivityRecord, :LeadRecord )
  ALL_TYPES      = #:nodoc:
    MarketoAPI.freeze(*[ GET_TYPES, DESCRIBE_TYPES ].flatten.uniq)

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

  # Associated objects.
  attr_reader   :associations
  # The stream position for paged queries.
  attr_accessor :stream_position

  ##
  # :attr_accessor: include_details
  # When getting a Marketo Program, the details will be included if this is
  # +true+.

  # The detailed attributes of the Marketo object.
  attr_reader   :attributes
  # The detailed types of the Marketo object.
  attr_reader   :types

  def initialize(type, id = nil)
    @type                = ensure_valid_type!(type)
    @id                  = id
    @attributes          = {}
    @criteria            = []
    @associations        = []
    @stream_position     = nil
    @include_details     = false
    @types               = Hash.new { |h, k| h[k] = {} }
    yield self if block_given?
  end

  def include_details
    @include_details
  end

  def include_details=(value) #:nodoc:
    @include_details= !!value
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
    @criteria << Criteria.new(name, value, comparison) if name
    @criteria
  end

  # Add association criteria for use with MarketoAPI::MObjects#get or
  # MarketoAPI::MOBjects#sync (not yet implemented).
  #
  # Type +type+ must be one of +Lead+, +Company+, or +Opportunity+. It must
  # be accompanied with one of the following parameters:
  #
  # id::        The Marketo ID of the associated object.
  # external::  The custom attribute value of the associated object. Can
  #             also be accessed as +external_key+.
  def association(type, options = {})
    @associations << Association.new(type, options)
    @associations
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
      include_details:         include_details,
      m_obj_criteria_list:     criteria.compact.uniq.map(&:to_h),
      m_obj_association_list:  associations.compact.uniq.map(&:to_h),
      stream_position:         stream_position
    }.delete_if(&MarketoAPI::MINIMIZE_HASH)
  end

  def ==(other)
    type == other.type &&
      include_details == other.include_details &&
      id == other.id &&
      stream_position == other.stream_position &&
      attributes == other.attributes &&
      types == other.types &&
      criteria == other.criteria &&
      associations == other.associations
  end

  class << self
    # Creates a new MObject from a SOAP response hash (from MObjects#get or
    # MObjects#sync).
    def from_soap_hash(hash) #:nodoc:
      new(hash[:type], hash[:id]) do |mobj|
        obj = hash[:attrib_list][:attrib]
        MarketoAPI.array(obj).each do |attrib|
          mobj.attributes[attrib[:name].to_sym] = attrib[:value]
        end

        obj = hash[:type_attrib_list][:type_attrib]
        MarketoAPI.array(obj).each do |type|
          MarketoAPI.array(type[:attr_list][:attrib]).each do |attrib|
            mobj.types[type[:attr_type].to_sym][attrib[:name].to_sym] =
              attrib[:value]
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

  class Criteria #:nodoc:
    TYPES = { #:nodoc:
      name:             "Name",
      role:             "Role",
      type:             "Type",
      stage:            "Stage",
      crm_id:           "CRM Id",
      created_at:       "Created At",
      updated_at:       "Updated At",
      tag_type:         "Tag Type",
      tag_value:        "Tag Value",
      workspace_name:   "Workspace Name",
      workspace_id:     "Workspace Id",
      include_archive:  "Include Archive"
    }.freeze
    TYPES.values.map(&:freeze)

    CMP  = [ #:nodoc:
      :EQ, :NE, :LT, :LE, :GT, :GE
    ]

    attr_reader :name, :value, :comparison

    def initialize(name, value, comparison)
      name = if TYPES.has_key?(name.to_sym)
               TYPES[name.to_sym]
             elsif TYPES.values.include?(name)
               TYPES.values[TYPES.values.index(name)]
             else
               raise ArgumentError, "Invalid type name [#{name}]"
             end

      unless CMP.include?(comparison.to_s.to_sym.upcase)
        raise ArgumentError, "Invalid comparison [#{comparison}]"
      end

      @name, @value, @comparison = name, value, comparison.to_sym.upcase
    end

    def ==(other)
      name.equal?(other.name) && comparison.equal?(other.comparison) &&
        value == other.value?
    end

    def to_h
      {
        attr_name:   name,
        attr_value:  value,
        comparison:  comparison
      }
    end
  end

  class Association #:nodoc:
    TYPES = [ #:nodoc:
      :Lead, :Company, :Opportunity
    ]

    attr_reader :type, :id, :external_key
    alias_method :external, :external_key

    def initialize(type, options = {})
      unless TYPES.include?(type.to_s.capitalize.to_sym)
        raise ArgumentError, "Invalid type #{type}"
      end

      @type = TYPES[TYPES.index(type.to_s.capitalize.to_sym)]

      options.fetch(:id) {
        options.fetch(:external) {
          options.fetch(:external_key) {
            raise KeyError, "Must have one of :id or :external"
          }
        }
      }

      @id = options[:id]
      @external_key = options[:external] || options[:external_key]
    end

    def ==(other)
      type.equal?(other.type) && id == other.id &&
        external_key == other.external_key
    end

    def to_h
      {
        m_obj_type:    type,
        id:            id,
        external_key:  external_key,
      }
    end
  end

  private
  def ensure_valid_type!(type, list = ALL_TYPES)
    unless list.include? type.to_sym
      raise ArgumentError, ":type must be one of #{list.join(", ")}"
    end
    type.to_sym
  end
end
