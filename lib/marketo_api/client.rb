require 'savon'
require 'openssl'

##
# The client to the Marketo SOAP API.
class MarketoAPI::Client
  DEFAULT_CONFIG = {
    api_subdomain:           '123-ABC-456',
    api_version:             '2_3',
    user_id:                 nil,
    encryption_key:          nil,
    read_timeout:            90,
    open_timeout:            90,
    headers:                 { 'Connection' => 'Keep-Alive' },
    env_namespace:           'SOAP-ENV',
    namespaces:              { 'xmlns:ns1' => 'http://www.marketo.com/mktows/' },
    pretty_print_xml:        true,
    ssl_verify_mode:         :none,
    convert_request_keys_to: :none,
  }.freeze
  DEFAULT_CONFIG.values.each(&:freeze)
  private_constant :DEFAULT_CONFIG

  # Sets the logger.
  attr_writer :logger

  # The targeted Marketo SOAP API version.
  attr_reader :api_version
  # The subdomain for interacting with Marketo.
  attr_reader :subdomain
  # The WSDL used for interacting with Marketo.
  attr_reader :wsdl
  # The computed endpoint for Marketo.
  attr_reader :endpoint
  # If the most recent call resulted in an exception, it will be captured
  # here.
  attr_reader :error

  # Creates a client to talk to the Marketo SOAP API.
  #
  # === Required Configuration Parameters
  #
  # The required configuration parameters can be found in your Marketo
  # dashboard, under Admin / Integration / SOAP API.
  #
  # +api_subdomain+::  The endpoint subdomain.
  # +api_version+::    The endpoint version.
  # +user_id+::        The user iD for SOAP integration.
  # +encryption_key+:: The encryption key for SOAP integration.
  #
  # Version 1.0 will make these values defaultable through environment
  # variables.
  #
  # === Savon Configuration Parameters
  #
  # These affect how Savon interacts with the HTTP server.
  #
  # +read_timeout+::     The timeout for reading from the server. Defaults
  #                      to 90.
  # +open_timeout+::     The timeout for opening the connection. Defaults to
  #                      90.
  # +pretty_print_xml+:: How the SOAP XML should be written. Defaults to
  #                      +true+.
  # +ssl_verify_mode+::  How to verify SSL keys. This version defaults to
  #                      +none+. Version 1.0 will default to normal
  #                      verification.
  # +headers+::          Headers to use. Defaults to Connection: Keep-Alive.
  #                      Version 1.0 will enforce at least this value.
  #
  # Version 1.0 will require that these options be provided under a +savon+
  # key.
  def initialize(config = {})
    config = DEFAULT_CONFIG.merge(config)
    @api_version = config.delete(:api_version).freeze
    @subdomain = config.delete(:api_subdomain).freeze

    @logger = config.delete(:logger)

    user_id = config.delete(:user_id)
    encryption_key = config.delete(:encryption_key)
    @auth = AuthHeader.new(user_id, encryption_key)

    @wsdl = "http://app.marketo.com/soap/mktows/#{api_version}?WSDL".freeze
    @endpoint = "https://#{subdomain}.mktoapi.com/soap/mktows/#{api_version}".freeze
    @savon = Savon.client(config.merge(wsdl: wsdl, endpoint: endpoint))
  end

  # Indicates the presence of an error from the last call.
  def error?
    !!@error
  end

  ##
  # :attr_reader: campaigns
  # The MarketoAPI::Campaigns instance using this Client.

  ##
  # :attr_reader: leads
  # The MarketoAPI::Leads instance using this Client.

  ##
  # :attr_reader: lists
  # The MarketoAPI::Lists instance using this Client.

  ##
  # :attr_reader: mobjects
  # The MarketoAPI::MObjects instance using this Client.

  # Perform a SOAP API request with a properly formatted params message
  # object.
  #
  # *Warning*: This method is for internal use by descendants of
  # MarketoAPI::ClientProxy. It should not be called by external users.
  def call(web_method, params) #:nodoc:
    @error = nil
    @savon.call(
      web_method,
      message: params,
      soap_header: { 'ns1:AuthenticationHeader' => @auth.signature }
    ).to_hash
  rescue Exception => e
    @error = e
    @logger.log(e) if @logger
    nil
  end

  private
  # Implements the Marketo
  # {Authentication Signature}[http://developers.marketo.com/documentation/soap/signature-algorithm/].
  class AuthHeader #:nodoc:
    DIGEST = OpenSSL::Digest.new('sha1')
    private_constant :DIGEST

    def initialize(user_id, encryption_key)
      if user_id.nil? || encryption_key.nil?
        raise ArgumentError, ":user_id and :encryption_key required"
      end

      @user_id = user_id
      @encryption_key = encryption_key
    end

    attr_reader :user_id

    # Compute the HMAC signature and return it.
    def signature
      time = Time.now
      {
        mktowsUserId:      user_id,
        requestTimestamp:  time.to_s,
        requestSignature:  hmac(time),
      }
    end

    private
    def hmac(time)
      OpenSSL::HMAC.hexdigest(
        DIGEST,
        @encryption_key,
        "#{time}#{user_id}"
      )
    end
  end
  private_constant :AuthHeader
end

require_relative 'campaigns'
require_relative 'leads'
require_relative 'lists'
require_relative 'mobjects'
