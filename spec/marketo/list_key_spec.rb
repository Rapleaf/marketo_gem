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

    TEST_KEY_VALUE = 'a value'
    TEST_KEY_TYPE = LeadKeyType::IDNUM

    describe LeadKey do
      it "should store type and value on construction" do

        lead_key = LeadKey.new(TEST_KEY_VALUE, TEST_KEY_VALUE)
        lead_key.key_type.should == TEST_KEY_VALUE
        lead_key.key_value.should == TEST_KEY_VALUE
      end

      it "should to_hash correctly" do
        lead_key = LeadKey.new(TEST_KEY_VALUE, TEST_KEY_VALUE)

        lead_key.to_hash.should == {
            :key_type => TEST_KEY_VALUE,
            :key_value => TEST_KEY_VALUE
        }
      end
    end
  end
end
