require "minitest_helper"

class TestMarketoAPIClient < Minitest::Test
  include MarketoTestHelper

  def setup
    super
    @subject = @client
  end

  def test_api_version
    assert_equal '2_3', subject.api_version
    assert_equal '2_4', setup_client(api_version: '2_4').api_version
  end

  def test_subdomain
    assert_equal '123-ABC-456', subject.subdomain
    assert_equal 'testable', setup_client(api_subdomain: 'testable').subdomain
  end

  def test_wsdl
    assert_equal "http://app.marketo.com/soap/mktows/2_3?WSDL",
      subject.wsdl
    assert_equal "http://app.marketo.com/soap/mktows/2_4?WSDL",
      setup_client(api_version: '2_4').wsdl
  end

  def test_endpoint
    assert_equal "https://123-ABC-456.mktoapi.com/soap/mktows/2_3",
      subject.endpoint
    assert_equal "https://testable.mktoapi.com/soap/mktows/2_4",
      setup_client(api_subdomain: 'testable', api_version: '2_4').endpoint
  end

  def test_generated_methods
    assert subject.respond_to? :campaigns
    assert subject.respond_to? :leads
    assert subject.respond_to? :lists
    assert subject.respond_to? :mobjects
    refute subject.respond_to? :customobjects
  end

  def stub_savon callable = nil, &block
    callable ||= ->(*args) {
      def args.to_hash
        self
      end

      args
    }

    subject.instance_variable_get(:@savon).stub :call, callable do
      block.call if block
    end
  end

  def test_call_exception_suppressed
    stub_savon -> { raise ArgumentError } do
      assert_nil subject.call(:web_method, {})
      assert subject.error?
      refute_nil subject.error
      assert_instance_of ArgumentError, subject.error
    end
  end

  def test_call_with_auth
    time = Time.now.to_i

    signature = {
      mktowsUserId:      'user',
      requestTimestamp:  time.to_s,
      requestSignature:  OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha1'),
        'key',
        "#{time}user"
      )
    }

    Time.stub :now, -> { time } do
      stub_savon do
        method, params = subject.call(:web_method, {})
        assert_equal :web_method, method
        assert_equal({
          message: {},
          soap_header: { 'ns1:AuthenticationHeader' => signature }
        }, params)
      end
    end
  end
end
