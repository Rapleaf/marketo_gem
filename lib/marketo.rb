require 'rubygems'
require 'savon'

Savon.configure do |config|
  config.log = false # disable logging
end

require File.expand_path('marketo/client', File.dirname(__FILE__))
require File.expand_path('marketo/authentication_header', File.dirname(__FILE__))
require File.expand_path('marketo/enums', File.dirname(__FILE__))
require File.expand_path('marketo/lead_key', File.dirname(__FILE__))
require File.expand_path('marketo/lead_record', File.dirname(__FILE__))




