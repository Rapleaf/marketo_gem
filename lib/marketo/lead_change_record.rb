module Marketo
  # Represents a marketo change record
  class LeadChangeRecord
    def initialize(activity_date_time = nil, activity_type = nil, idnum = nil)
      @activity_date_time = activity_date_time
      @activity_type = activity_type
      @idnum = idnum.to_i
      @attributes = {}
    end

    # hydrates an instance from a savon hash returned form the marketo API
    def self.from_hash(savon_hash)
      r = LeadChangeRecord.new(savon_hash[:activity_date_time], savon_hash[:activity_type], savon_hash[:id])
      savon_hash[:activity_attributes][:attribute].each do |attribute|
        r.set_attribute(attribute[:attr_name], attribute[:attr_value])
      end
      r
    end

    # get the record idnum
    def idnum
      @idnum
    end

    def attributes
      @attributes
    end

    # update the value of the named attribute
    def set_attribute(name, value)
      @attributes[name] = value
    end

    # get the value for the named attribute
    def get_attribute(name)
      @attributes[name]
    end

    # will yield pairs of |attribute_name, attribute_value|
    def each_attribute_pair(&block)
      @attributes.each_pair do |name, value|
        block.call(name, value)
      end
    end

    def ==(other)
      @attributes == other.attributes &&
      @idnum == other.idnum
    end
  end
end
