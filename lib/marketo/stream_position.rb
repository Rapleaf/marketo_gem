module Marketo
  class StreamPosition
    def initialize(oldestCreatedAt)
      @oldestCreatedAt = oldestCreatedAt
    end

    # get the oldestCreatedAt
    def oldestCreatedAt
      @oldestCreatedAt
    end


    # create a hash from this instance, for sending this object to marketo using savon
    def to_hash
      {
          :oldestCreatedAt => @oldestCreatedAt.to_s
      }
    end
  end
end
