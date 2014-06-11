# -*- ruby encoding: utf-8 -*-

if ENV['MARKETO_USER_ID']
  require "minitest_helper"
  begin
    verbose, $VERBOSE = $VERBOSE, nil
    require 'debugger'
  ensure
    $VERBOSE = verbose
  end

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

      def test_02_create_lead
        lead = subject.new(email: @email) do |l|
          l[:FirstName] = 'George'
          l[:LastName]  = 'of the Jungle'
        end
        refute_nil lead.sync!
        refute_nil lead.id
      end
    end
  end
end
