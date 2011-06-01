module Rapleaf
  module Marketo
    # Encapsulates a key used to look up or describe a specific marketo lead.
    class LeadKey
      # - *key_type* the type of key to use see LeadKeyType
      # - *key_value* normally a string value for the given type
      def initialize(key_type, key_value)
        @key_type = key_type
        @key_value = key_value
      end

      # get the key type
      def key_type
        @key_type
      end

      # get the key value
      def key_value
        @key_value
      end

      # create a hash from this instance, for sending this object to marketo using savon
      def to_hash
        {
            :key_type => @key_type,
            :key_value => @key_value
        }
      end
    end
  end
end