# -*- ruby encoding: utf-8 -*-

require 'marketo-api-ruby'

def try_require(resource)
  require resource
  yield if block_given?
rescue LoadError
end

gem 'minitest'
require 'minitest/autorun'
try_require 'minitest/emoji'

module HashKeyAssertions
  def assert_missing_keys object, *keys
    keys.each { |key| refute object.has_key? key }
  end

  def refute_missing_keys object, *keys
    keys.each { |key| assert object.has_key? key }
  end
end

module ExceptionMessageAssertions
  def assert_raises_with_message exception_class, message, &block
    exception_message = nil
    assert_raises(exception_class) do
      begin
        block.call
      rescue exception_class => exception
        exception_message = exception.message
        raise
      end
    end
    assert_equal message, exception_message
  end
end

module MarketoTestHelper
  def self.included(mod)
    mod.send(:include, HashKeyAssertions)
    mod.send(:include, ExceptionMessageAssertions)
  end

  ARGS_STUB = ->(*args) {
    args = args.flatten(1)

    def args.to_hash
      self
    end

    args
  }

  def setup
    super
    @client = setup_client
  end

  def setup_client(options = {})
    MarketoAPI.client(options.merge(user_id: 'user', encryption_key: 'key'))
  end

  attr_reader :subject

  def stub_specialized method, object = subject, &block
    object.stub method, ARGS_STUB do
      block.call if block
    end
  end

  def stub_soap_call object = subject, &block
    object.stub :call, ARGS_STUB do
      block.call if block
    end
  end

  def lead_key *ids
    keys = ids.map { |id| MarketoAPI::Lead.key(:id, id) }
    case
    when keys.empty?
      nil
    when keys.size == 1
      keys.first
    else
      keys
    end
  end
  alias_method :lead_keys, :lead_key
end

module MarketoIntegrationHelper
  def self.included(mod)
    puts "#{mod.name} will be run."
    mod.send(:include, HashKeyAssertions)
    mod.send(:include, ExceptionMessageAssertions)
  end

  attr_reader :client

  def setup
    super
    @client  = MarketoAPI.client(api_subdomain:  ENV['MARKETO_SUBDOMAIN'],
                                 user_id:        ENV['MARKETO_USER_ID'],
                                 encryption_key: ENV['MARKETO_ENCRYPTION_KEY'])
    @verbose, $VERBOSE = $VERBOSE, nil
  end

  def teardown
    $VERBOSE = @verbose
  end
end
