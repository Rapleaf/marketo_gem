require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Grabcad
  module Marketo
    describe ListKeyType do
      it "should define the correct types" do
        ListKeyType::MKTOLISTNAME.should == 'MKTOLISTNAME'
        ListKeyType::MKTOSALESUSERID.should == 'MKTOSALESUSERID'
        ListKeyType::SFDCLEADOWNERID.should == 'SFDCLEADOWNERID'

      end
    end

    describe ListKey do
      TEST_LIST_KEY_VALUE = 'a value'
      TEST_LIST_KEY_TYPE = "key type"
      
      it "should store type and value on construction" do

        lead_key = ListKey.new(TEST_LIST_KEY_TYPE, TEST_LIST_KEY_VALUE)
        lead_key.key_type.should == TEST_LIST_KEY_TYPE
        lead_key.key_value.should == TEST_LIST_KEY_VALUE
      end

      it "should to_hash correctly" do
        lead_key = ListKey.new(TEST_LIST_KEY_TYPE, TEST_LIST_KEY_VALUE)

        lead_key.to_hash.should == {
            :key_type => TEST_LIST_KEY_TYPE,
            :key_value => TEST_LIST_KEY_VALUE
        }
      end
    end
  end
end
