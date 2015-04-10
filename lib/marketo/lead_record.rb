module Rapleaf
  module Marketo
    # Represents a record of the data known about a lead within marketo
    class LeadRecord
      def initialize(email, idnum = nil)
        @idnum      = idnum
        @attributes = {}
        set_attribute('Email', email)
      end

      # hydrates an instance from a savon hash returned form the marketo API
      def self.from_hash(savon_hash)
        lead_record = LeadRecord.new(savon_hash[:email], savon_hash[:id].to_i)
        attributes = savon_hash[:lead_attribute_list][:attribute]
        (attributes.is_a?(Array) ? attributes : [attributes]).each do |attribute|
          lead_record.set_attribute(attribute[:attr_name], attribute[:attr_value])
        end
        lead_record
      end

      # get the record idnum
      def idnum
        @idnum
      end

      # get the record email
      def email
        get_attribute('Email')
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
        return false unless other.respond_to?(:attributes) && other.respond_to?(:idnum)
        @attributes == other.attributes && @idnum == other.idnum
      end
    end
  end
end