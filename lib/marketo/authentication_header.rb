module Rapleaf
  module Marketo
    # This class exists only to encapsulate the authentication header part of a soap request to marketo
    # Marketo requires a somewhat complex calculation of an encrypted signature and so it seemed sensible to pull this code out here
    class AuthenticationHeader
      DIGEST = OpenSSL::Digest::Digest.new('sha1')

      def initialize(access_key, secret_key, time = DateTime.now)
        @access_key = access_key
        @secret_key = secret_key
        @time       = time
      end

      public
      # time should be a DateTime instance
      def set_time(time)
        @time = time
      end

      def get_mktows_user_id
        @access_key
      end

      def get_request_signature
        calculate_signature
      end

      def get_request_timestamp
        @time.to_s
      end

      def to_hash
        {
            "mktowsUserId"     => get_mktows_user_id,
            "requestSignature" => get_request_signature,
            "requestTimestamp" => get_request_timestamp
        }
      end

      private
      def calculate_signature
        request_timestamp = get_request_timestamp
        string_to_encrypt = request_timestamp + @access_key
        OpenSSL::HMAC.hexdigest(DIGEST, @secret_key, string_to_encrypt)
      end
    end
  end
end