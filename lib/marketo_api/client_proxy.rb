require 'forwardable'

# The ClientProxy is the base class for implementing Marketo APIs in a
# fluent manner. When a descendant class is implemented, a method will be
# added to MarketoAPI::Client based on the descendant class name that will
# provide an initialized instance of the descendant class using the
# MarketoAPI::Client instance.
#
# This base class does not provide any useful functionality for consumers of
# MarketoAPI, and is primarily provided for common functionality.
#
# As an example, MarketoAPI::Client#campaigns was generated when
# MarketoAPI::Campaigns was inherited from MarketoAPI::ClientProxy. It
# returns an instance of MarketoAPI::Campaigns intialized with the
# MarketoAPI::Client that generated it.
class MarketoAPI::ClientProxy
  extend Forwardable

  class << self
    # Generates a new method on MarketoAPI::Client based on the inherited
    # class name.
    def inherited(klass)
      name = klass.name.split(/::/).last.downcase.to_sym
      varn = :"@#{name}"

      MarketoAPI::Client.send(:define_method, name) do
        instance_variable_get(varn) ||
          instance_variable_set(varn, klass.new(self))
      end
    end
  end

  def initialize(client)
    @client = client
  end

  ##
  # :attr_reader: error
  #
  # Reads the error attribute from the proxied client.

  ##
  # :method: error?
  #
  # Reads the presence of an error from the proxied client.

  def_delegators :@client, :error, :error?

  private
  # Performs a SOAP call and extracts the result from a successful result.
  #
  # The Marketo SOAP API always returns results in a fairly deep structure.
  # For example, the SOAP response for requestCampaign looks something like:
  #
  #     &lt;successRequestCampaign&gt;
  #       &lt;result&gt;
  #       &lt;/result&gt;
  #     &lt;/successRequestCampaign&gt;
  def call(method, param, &block)
    extract_from_response(
      @client.call(method, param),
      :"success_#{method}",
      :result,
      &block
    )
  end

  # Takes a parameter list and calls #transform_param on each parameter.
  def transform_param_list(method, param_list)
    method = :"params_for_#{method}"
    param_list.map { |param|
      transform_param(nil, param, method)
    }.compact
  end

  # Takes a provided a parameter and transforms it. If the parameter is a
  # Hash or +nil+, there is no transformation performed; if it responds to a
  # method <tt>params_for_#{method}</tt>, that method is called to transform
  # the object.
  #
  # If neither of these is true, an ArgumentError is raised.
  def transform_param(method, param, override = nil)
    method = if override
               override
             else
               :"params_for_#{method}"
             end
    if param.kind_of? Hash or param.nil?
      param
    elsif param.respond_to? method
      param.send(method)
    else
      raise ArgumentError, "Invalid parameter: #{param.inspect}"
    end
  end

  # Given a response hash (which is deeply nested), follows the key path
  # down.
  def extract_from_response(response, *paths)
    paths.each { |path| response &&= response[path] }
    response = yield response if response and block_given?
    response
  end
end
