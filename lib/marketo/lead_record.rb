module Grabcad
  module Marketo
    # Represents a record of the data known about a lead within marketo
    class LeadRecord
      attr_reader :id, :attributes

      def initialize(client, email, lead_id = nil, attrs = nil)
        @client = client
        @id = lead_id
        @attributes = {}
        if (attrs)
          populate_from attrs
        end
        set_attribute('Email', email)
      end

      # creates and populates an instance from a savon hash returned form the marketo API
      def self.from_hash(client, lead_hash)
        # if there's more than one lead, take the first one.
        if lead_hash.kind_of? Array
          lead_hash = lead_hash[0]
        end
        lead_record = LeadRecord.new(client, lead_hash[:email], lead_hash[:id].to_i, lead_hash)
      end

      def sync
        if @id
          populate_from @client.sync_lead_record_by_id(self)
        else
          populate_from @client.sync_lead_record_by_email(self)
        end
      end

      # get the record email
      def email
        get_attribute('Email')
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
        @id == other.id
      end

      private

      def populate_from(lead_hash)
        begin
        @id = lead_hash[:id].to_i
        lead_attributes = lead_hash[:lead_attribute_list]
        if lead_attributes # if no attributes set
          attrs = lead_attributes[:attribute]
          if attrs.kind_of?(Array) # if only one attribute set, service doesn't return an array
            attrs.each do |attribute|
              set_attribute(attribute[:attr_name], attribute[:attr_value])
            end
          else
            set_attribute(attrs[:attr_name], attrs[:attr_value])
          end
        end
        self
        rescue Exception => e
          client.log_exception e
          nil
        end
      end
    end
  end
end