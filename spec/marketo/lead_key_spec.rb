require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Rapleaf
  module Marketo
    describe LeadKeyType do
      it "should define the correct types" do
        LeadKeyType::IDNUM.should == 'IDNUM'
        LeadKeyType::COOKIE.should == 'COOKIE'
        LeadKeyType::EMAIL.should == 'EMAIL'
        LeadKeyType::LEADOWNEREMAIL.should == 'LEADOWNEREMAIL'
        LeadKeyType::SFDCACCOUNTID.should == 'SFDCACCOUNTID'
        LeadKeyType::SFDCCONTACTID.should == 'SFDCCONTACTID'
        LeadKeyType::SFDCLEADID.should == 'SFDCLEADID'
        LeadKeyType::SFDCLEADOWNERID.should == 'SFDCLEADOWNERID'
        LeadKeyType::SFDCOPPTYID.should == 'SFDCOPPTYID'
      end
    end

    describe LeadKey do
      it "should store type and value on construction" do
        key_value = 'a value'
        key_type = LeadKeyType::IDNUM
        lead_key = LeadKey.new(key_type, key_value)
        lead_key.key_type.should == key_type
        lead_key.key_value.should == key_value
      end

      it "should to_hash correctly" do
        key_value = 'a value'
        key_type = LeadKeyType::IDNUM
        lead_key = LeadKey.new(key_type, key_value)

        lead_key.to_hash.should == {
            :key_type => key_type,
            :key_value => key_value
        }
      end
    end
  end
end
