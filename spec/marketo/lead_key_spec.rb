require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Grabcad
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
      TEST_LEAD_KEY_VALUE = 'a value'
      TEST_LEAD_KEY_TYPE = "test key"
      
      it "should store type and value on construction" do

        lead_key = LeadKey.new(TEST_LEAD_KEY_TYPE, TEST_KEY_VALUE)
        lead_key.key_type.should == TEST_LEAD_KEY_TYPE
        lead_key.key_value.should == TEST_LEAD_KEY_VALUE
      end

      it "should to_hash correctly" do
        lead_key = LeadKey.new(TEST_LEAD_KEY_TYPE, TEST_LEAD_KEY_VALUE)

        lead_key.to_hash.should == {
            :key_type => TEST_LEAD_KEY_TYPE,
            :key_value => TEST_LEAD_KEY_VALUE
        }
      end
    end
  end
end
