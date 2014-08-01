# -*- ruby encoding: utf-8 -*-

if ENV['MARKETO_USER_ID']
  require "minitest_helper"
  begin
    verbose, $VERBOSE = $VERBOSE, nil
    require 'debugger'
  rescue LoadError
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
        @email   = "bit#{$run_id}+integration@clearfit.org"
        @fault = {
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
      end

      def test_01_lead_is_missing
        assert_nil subject.get_by_email(@email)
        assert subject.error?

        assert_equal @fault, subject.error.to_hash
      end

      def test_02_create_lead
        lead = subject.new(email: @email) do |l|
          l[:FirstName] = 'George'
          l[:LastName]  = 'of the Jungle'
        end
        refute_nil lead.sync!
        refute_nil lead.id
      end

      def test_03_load_lead
        lead = subject.get_by_email(@email)

        refute_nil lead
        refute_nil lead.id
        assert_equal 'George', lead[:FirstName]
        assert_equal @email, lead[:Email]
      end

      def test_04_change_lead_name
        george = subject.get_by_email(@email)
        george[:FirstName] = 'Ursula'
        george[:LastName]  = 'Stanhope'

        ursula = george.sync
        refute_equal george.object_id, ursula.object_id
        assert_equal george.id, ursula.id
        assert_equal george[:FirstName], ursula[:FirstName]
        assert_equal george[:LastName], 'Stanhope'

        assert_equal subject.get_by_email(@email)[:LastName], 'Stanhope'
      end

      def test_05_change_lead_email
        lead = subject.get_by_email(@email)
        email = @email.gsub(/\.org/, '.com')
        lead[:Email] = email

        lead2 = lead.sync
        refute_equal lead.object_id, lead2.object_id
        assert_equal lead.id, lead2.id
        assert_equal lead[:FirstName], lead2[:FirstName]
        assert_equal lead[:LastName], 'Stanhope'
        assert_equal lead2[:Email], email

        assert_equal subject.get_by_email(email)[:LastName], 'Stanhope'

        test_01_lead_is_missing

        lead[:Email] = @email

        refute_nil lead.sync!
      end
    end
  end
else
  puts 'No MARKETO_USER_ID'
end
