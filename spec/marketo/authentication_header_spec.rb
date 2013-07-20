require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Grabcad
  module Marketo
    #Test values from Marketo API docs
    TEST_ACCESS_KEY = 'bigcorp1_461839624B16E06BA2D663'
    TEST_SECRET_KEY = '899756834129871744AAEE88DDCC77CDEEDEC1AAAD66'
    TEST_DATE = DateTime.new(2010, 4, 9, 14, 4, 54, -7/24.0)
    TEST_DATE_STRING = '2010-04-09T14:04:54-07:00'
    TEST_SIGNATURE = 'ffbff4d4bef354807481e66dc7540f7890523a87'


    # hash keys with names from Marketo API
    SIGNATURE_KEY = 'requestSignature'
    USER_KEY = 'mktowsUserId'
    TIMESTAMP_KEY = 'requestTimestamp'

    # expected structure of hash output
    TEST_HASH = {
      USER_KEY => TEST_ACCESS_KEY,
      SIGNATURE_KEY => TEST_SIGNATURE,
      TIMESTAMP_KEY => TEST_DATE_STRING,
    }

    describe AuthenticationHeader do
      describe "tests with 3-argument constructor" do
        before(:each) do
          @auth_header = Grabcad::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY, TEST_DATE)
          @auth_hash = @auth_header.to_hash
        end

        it "to_hash should create the proper hash for known inputs" do
          @auth_hash.should == TEST_HASH
        end
        it "hash should change if time changes" do
          @auth_header.set_time(DateTime.now)
          hash = @auth_header.to_hash
          @auth_hash[USER_KEY].should == hash[USER_KEY]
          @auth_hash[SIGNATURE_KEY].should_not == hash[SIGNATURE_KEY]
          @auth_hash[TIMESTAMP_KEY].should_not == hash[TIMESTAMP_KEY]
        end
      end
      
      describe "tests with 2-argument constructor" do
        before(:each) do
          @auth_header = Grabcad::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY)
          @auth_hash = @auth_header.to_hash
        end
        it "should format the time correctly" do
          @auth_header.set_time(TEST_DATE)
          @auth_header.to_hash[TIMESTAMP_KEY].should == TEST_DATE_STRING
        end
        it "should create a hash with the default time" do
          @auth_hash[USER_KEY].should be_a(String)
          @auth_hash[SIGNATURE_KEY].should be_a(String)
          @auth_hash[TIMESTAMP_KEY].should be_a(String)
        end
      end
    end
  end
end
  #     it "should set mktowsUserId to access key" do
  #       header = Rapleaf::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY)
  #       header.get_mktows_user_id.should == TEST_ACCESS_KEY
  #     end

  #     it "should set requestSignature" do
  #       header = Rapleaf::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY)

  #       header.get_request_signature.should_not be_nil
  #       header.get_request_signature.should_not == ''
  #     end

  #     it "should set requestTimestamp in correct format" do
  #       header = Rapleaf::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY)
  #       header.set_time(TEST_DATE)

  #       header.get_request_timestamp().should == TEST_DATE_STRING
  #     end

  #     it "should calculate encrypted signature" do
  #       header     = Rapleaf::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY)
  #       header.set_time(TEST_DATE)

  #       header.get_request_timestamp.should == TEST_DATE_STRING
  #       header.get_request_signature.should == TEST_SIGNATURE
  #     end

  #     it "should cope if no date is given" do
  #       header   = Rapleaf::Marketo::AuthenticationHeader.new(TEST_ACCESS_KEY, TEST_SECRET_KEY)
  #       expected = DateTime.now
  #       actual   = DateTime.parse(header.get_request_timestamp)

  #       expected.year.should == actual.year
  #       expected.hour.should == actual.hour
  #     end

  #     it "should to_hash correctly" do
  #       # taken from marketo API docs

  #       access_key = 'bigcorp1_461839624B16E06BA2D663'
  #       secret_key = '899756834129871744AAEE88DDCC77CDEEDEC1AAAD66'

  #       header     = Rapleaf::Marketo::AuthenticationHeader.new(access_key, secret_key)
  #       header.set_time(DateTime.new(2010, 4, 9, 14, 4, 55, -7/24.0))

  #       header.to_hash.should == {
  #           'mktowsUserId'     => header.get_mktows_user_id,
  #           'requestSignature' => header.get_request_signature,
  #           'requestTimestamp' => header.get_request_timestamp,
  #       }
  #     end
  #   end
  # end
#end