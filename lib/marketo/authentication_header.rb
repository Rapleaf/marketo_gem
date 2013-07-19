module Grabcad
  module Marketo
    # This class exists only to encapsulate the authentication header part of a soap request to marketo
    # It contains a SHA1-based MAC based on a timestamp
    class AuthenticationHeader
      DIGEST = OpenSSL::Digest::Digest.new('sha1')

      def initialize(access_key, secret_key, time = DateTime.now)
        @access_key = access_key
        @secret_key = secret_key
        @time       = time
      end

      public
      def set_time(time)
        @time = time
      end

      def to_hash
        {
            "mktowsUserId"     => @access_key,
            "requestSignature" => calculate_signature,
            "requestTimestamp" => request_timestamp
        }
      end

      private
      def request_timestamp
        @time.to_s
      end

      def calculate_signature
        OpenSSL::HMAC.hexdigest(DIGEST, @secret_key, request_timestamp + @access_key)
      end
    end
  end
end