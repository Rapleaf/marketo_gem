require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Rapleaf
  module Marketo
    ACCESS_KEY = 'ACCESS_KEY'
    SECRET_KEY = 'SECRET_KEY'

    describe AuthenticationHeader do
      it "should set mktowsUserId to access key" do
        header = Rapleaf::Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
        header.get_mktows_user_id.should == ACCESS_KEY
      end

      it "should set requestSignature" do
        header = Rapleaf::Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
        header.get_request_signature.should_not be_nil
        header.get_request_signature.should_not == ''
      end

      it "should set requestTimestamp in correct format" do
        header = Rapleaf::Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
        time   = DateTime.new(1998, 1, 17, 20, 15, 1)
        header.set_time(time)
        header.get_request_timestamp().should == '1998-01-17T20:15:01+00:00'
      end

      it "should calculate encrypted signature" do
        # I got this example of the marketo API docs

        access_key = 'bigcorp1_461839624B16E06BA2D663'
        secret_key = '899756834129871744AAEE88DDCC77CDEEDEC1AAAD66'

        header     = Rapleaf::Marketo::AuthenticationHeader.new(access_key, secret_key)
        header.set_time(DateTime.new(2010, 4, 9, 14, 4, 55, -7/24.0))

        header.get_request_timestamp.should == '2010-04-09T14:04:54-07:00'
        header.get_request_signature.should == 'ffbff4d4bef354807481e66dc7540f7890523a87'
      end

      it "should cope if no date is given" do
        header   = Rapleaf::Marketo::AuthenticationHeader.new(ACCESS_KEY, SECRET_KEY)
        expected = DateTime.now
        actual   = DateTime.parse(header.get_request_timestamp)

        expected.year.should == actual.year
        expected.hour.should == actual.hour
      end

      it "should to_hash correctly" do
        # I got this example from the marketo API docs

        access_key = 'bigcorp1_461839624B16E06BA2D663'
        secret_key = '899756834129871744AAEE88DDCC77CDEEDEC1AAAD66'

        header     = Rapleaf::Marketo::AuthenticationHeader.new(access_key, secret_key)
        header.set_time(DateTime.new(2010, 4, 9, 14, 4, 55, -7/24.0))

        header.to_hash.should == {
            'mktowsUserId'     => header.get_mktows_user_id,
            'requestSignature' => header.get_request_signature,
            'requestTimestamp' => header.get_request_timestamp,
        }
      end
    end
  end
end