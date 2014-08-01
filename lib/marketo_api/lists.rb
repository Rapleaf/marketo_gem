require_relative 'client_proxy'

# Marketo list operations.
class MarketoAPI::Lists < MarketoAPI::ClientProxy
  NAMED_TYPES = { #:nodoc:
    name:                      :MKTOLISTNAME,
    sales_user_id:             :MKTOSALESUSERID,
    salesforce_lead_owner_id:  :SFDCLEADOWNERID
  }.freeze

  TYPES = NAMED_TYPES.values.freeze

  ##
  # :method: add
  # :call-seq:
  #   add(list_key, options)
  #
  # === Options
  #
  # +leads+::   Required. An array of Lead objects or lead keys. If both
  #             +leads+ and +lead+ are provided, they will be merged.
  # +lead+::    An alias for +leads+.
  # +strict+::  If +true+, the entire operation fails if any subset fails.
  #             Non-strict mode will complete everything it can and return
  #             errors for anything that failed.
  #
  # Add leads to a Marketo list.

  ##
  # :method: remove
  # :call-seq:
  #   remove(list_key, options)
  #
  # === Options
  #
  # +leads+::   Required. An array of Lead objects or lead keys. If both
  #             +leads+ and +lead+ are provided, they will be merged.
  # +lead+::    An alias for +leads+.
  # +strict+::  If +true+, the entire operation fails if any subset fails.
  #             Non-strict mode will complete everything it can and return
  #             errors for anything that failed.
  #
  # Add leads to a Marketo list.

  ##
  # :method: member?
  # :call-seq:
  #   member?(list_key, options)
  #
  # === Options
  #
  # +leads+::   Required. An array of Lead objects or lead keys. If both
  #             +leads+ and +lead+ are provided, they will be merged.
  # +lead+::    An alias for +leads+.
  # +strict+::  If +true+, the entire operation fails if any subset fails.
  #             Non-strict mode will complete everything it can and return
  #             errors for anything that failed.
  #
  # Add leads to a Marketo list.

  {
    add:      :ADDTOLIST,
    remove:   :REMOVEFROMLIST,
    member?:  :ISMEMBEROFLIST,
  }.each do |name, operation|
    define_method(name) do |list_key, options = {}|
      list_operation(operation, list_key, options)
    end
  end

  class << self
    def key(type, value)
      {
        listKey: {
          keyType:  key_type(type),
          keyValue: value
        }
      }
    end

    private
    def key_type(key)
      res = if TYPES.include? key
              key
            else
              NAMED_TYPES[key]
            end
      raise ArgumentError, "Invalid key #{key}" unless res
      res
    end
  end

  private
  def list_operation(operation, list_key, options = {})
    leads = MarketoAPI.array(options.delete(:leads)) +
      MarketoAPI.array(options.delete(:lead))
    if leads.empty?
      raise ArgumentError, ':lead or :leads must be provided'
    end

    call(
      :list_operation,
      listOperation:  operation,
      listKey:        list_key,
      strict:         false,
      listMemberList: transform_param_list(:get, leads)
    )
  end
end
