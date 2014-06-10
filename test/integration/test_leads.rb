if ENV['MARKETO_USER_ID']
  require "minitest_helper"
  require 'debugger'

  $run_id = Time.now.strftime('%Y%j-%H%M%S')

  module Integration
    class TestMarketoAPILeads < Minitest::Test
      include MarketoIntegrationHelper

      # Integration tests depend on a particular order.
      def self.test_order
        :alpha
      end

      attr_reader :subject, :email

      def setup
        super
        @subject = @client.leads
        @email   = "#{$run_id}@integration.test"
      end

      def test_01_lead_is_missing
        assert_nil subject.get_by_email(@email)
        assert subject.error?

        expected = {
          :fault => {
            :faultcode   => 'SOAP-ENV:Client',
            :faultstring => '20103 - Lead not found',
            :detail => {
              :service_exception => {
                :name         => "mktServiceException",
                :message      => "No lead found with EMAIL = #{@email} (20103)",
                :code         => "20103",
                :"@xmlns:ns1" => "http://www.marketo.com/mktows/"
              }
            }
          }
        }
        assert_equal expected, subject.error.to_hash
      end
    end
  end
end
