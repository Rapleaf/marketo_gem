module Marketo
  class StreamPosition
    def initialize(oldestCreatedAt, latestCreatedAt=nil)
      @oldestCreatedAt = oldestCreatedAt
      @latestCreatedAt = latestCreatedAt
    end

    # get the oldestCreatedAt
    def oldestCreatedAt
      @oldestCreatedAt
    end

    def latestCreatedAt
      @latestCreatedAt
    end


    # create a hash from this instance, for sending this object to marketo using savon
    def to_hash
      {
          :oldestCreatedAt => @oldestCreatedAt.to_s,
          :latestCreatedAt => @latestCreatedAt.to_s
      }
    end
  end
end
