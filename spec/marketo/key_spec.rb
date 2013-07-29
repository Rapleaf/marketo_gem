require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Grabcad
  module Marketo


    describe Key do

      TEST_KEY_VALUE = 'a value'
      TEST_KEY_TYPE = "type"

      it "should store type and value on construction" do

        key = Key.new(TEST_KEY_TYPE, TEST_KEY_VALUE)
        key.key_type.should == TEST_KEY_TYPE
        key.key_value.should == TEST_KEY_VALUE
      end

      it "should to_hash correctly" do
        key = Key.new(TEST_KEY_TYPE, TEST_KEY_VALUE)

        key.to_hash.should == {
            :key_type => TEST_KEY_TYPE,
            :key_value => TEST_KEY_VALUE
        }
      end
    end
  end
end
