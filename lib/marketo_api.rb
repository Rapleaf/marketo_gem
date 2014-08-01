# MarketoAPI (marketo-api-ruby) provides a native Ruby interface to the
# {Marketo SOAP API}[http://developers.marketo.com/documentation/soap/],
# using {savon}[https://github.com/savonrb/savon].
#
# == Synopsis
#
#   require 'marketo_api'
module MarketoAPI
  VERSION = "0.9.2"

  MINIMIZE_HASH = ->(k, v) { #:nodoc:
    v.nil? or (v.respond_to?(:empty?) and v.empty?)
  }

  class << self
    # Create a new MarketoAPI::Client, essentially an alias for
    # MarketoAPI::Client.new.
    def client(config = {})
      MarketoAPI::Client.new(config)
    end

    def array(object) # :nodoc:
      case object
      when Hash
        [ object ]
      when Array
        object
      else
        Kernel.Array(object)
      end
    end

    def freeze(*args) # :nodoc:
      args.each(&:freeze).freeze
    end
  end
end

require 'marketo_api/client'
