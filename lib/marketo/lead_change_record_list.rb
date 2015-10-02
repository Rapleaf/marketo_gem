module Marketo
  # Represents a set of change records along with info about whether there are more
  class LeadChangeRecordList
    def initialize(records = nil, remaining = nil, new_start_position = nil)
      @records = records
      @remaining = remaining.to_i
      @new_start_position = new_start_position
    end

    # hydrates an instance from a savon hash returned form the marketo API
    def self.from_hash(savon_hash)
      records_hash = savon_hash[:lead_change_record_list] 
      records = records_hash.present? ? records_hash[:lead_change_record].map {|h| LeadChangeRecord.from_hash(h)} : []
      return LeadChangeRecordList.new(records, savon_hash[:remaining_count], savon_hash[:new_start_position])
    end
    
    def records
      @records
    end

    def count
      @records.count
    end

    def remaining_count
      @remaining
    end
    
    def new_start_position
      @new_start_position
    end
  end
end
