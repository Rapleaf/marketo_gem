module Marketo
  # Encapsulates a key used to look up or describe a specific marketo lead.
  class ActivityTypeFilter
    # - *key_type* the type of key to use see LeadKeyType
    # - *key_value* normally a string value for the given type
    def initialize(includes)
      @includes = includes.to_a
    end

    # create a hash from this instance, for sending this object to marketo using savon
    def to_hash
      {
        :include_types => 
        {
          :activity_type => @includes
        }
      }
    end
  end
end
