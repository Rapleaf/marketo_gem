require 'savon'

Savon.configure do |config|
  config.log = false # disable logging
end

require 'marketo/authentication_header'
require 'marketo/client'
require 'marketo/enums'
require 'marketo/lead_key'
require 'marketo/lead_record'
require 'marketo/lead_change_record'
require 'marketo/lead_change_record_list'
require 'marketo/stream_position'
require 'marketo/activity_type_filter'
