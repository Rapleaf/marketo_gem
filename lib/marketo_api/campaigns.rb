require_relative 'client_proxy'

# Implements Campaign-related calls for Marketo.
#
# === Sources
#
# Campaigns have a source, which the Marketo SOAP API provides as +MKTOWS+
# and +SALES+. MarketoAPI provides these values as the friendlier values
# +marketo+ and +sales+, but accepts the standard Maketo SOAP API
# enumeration values.
class MarketoAPI::Campaigns < MarketoAPI::ClientProxy
  SOURCES = { #:nodoc:
    marketo: :MKTOWS,
    sales:   :SALES,
  }.freeze
  private_constant :SOURCES

  ENUMS = MarketoAPI.freeze(*SOURCES.values) #:nodoc:
  private_constant :ENUMS

  # Implements
  # {+getCampaignsForSource+}[http://developers.marketo.com/documentation/soap/getcampaignsforsource/].
  #
  # If possible, prefer the generated methods #for_marketo and #for_sales.
  #
  # :call-seq:
  #   for_source(source)
  #   for_source(source, name)
  #   for_source(source, name, exact_name)
  def for_source(source, name = nil, exact_name = nil)
    call(
      :get_campaigns_for_source,
      source:      resolve_source(source),
      name:        name,
      exact_name:  exact_name
    )
  end

  ##
  # :method: for_marketo
  #
  # Implements +getCampaignsForSource+ for the +marketo+ source; a
  # specialization of #for_source.
  #
  # :call-seq:
  #   for_marketo()
  #   for_marketo(name)
  #   for_marketo(name, exact_name)

  ##
  # :method: for_sales
  #
  # Implements +getCampaignsForSource+ for the +sales+ source; a
  # specialization of #for_source.
  #
  # :call-seq:
  #   for_sales()
  #   for_sales(name)
  #   for_sales(name, exact_name)

  # Implements
  # {+requestCampaign+}[http://developers.marketo.com/documentation/soap/requestcampaign/].
  #
  # === Parameters
  #
  # +source+::         Required. The source of the campaign.
  # +leads+::          Required. An array of Lead objects or lead keys. If
  #                    both +leads+ and +lead+ are provided, they will be
  #                    merged.
  # +lead+::           An alias for +leads+.
  # +campaign_id+::    The campaign ID to request for the +lead+ or +leads+.
  #                    Required if +campaign_name+ or +program_name+ are not
  #                    provided.
  # +campaign_name+::  The campaign name to request for the +lead+ or
  #                    +leads+. Required if +campaign_id+ or +program_name+
  #                    are not provided.
  # +program_name+::   The program name to request for the +lead+ or
  #                    +leads+. Required if +campaign_id+ or +campaign_name+
  #                    are not provided, or if +program_tokens+ are
  #                    provided.
  # +program_tokens+:: An array of program tokens in the form:
  #                    <tt>{ attrib: { name: name, value: value } }</tt>
  #                    This will be made easier to manage in the future.
  #
  # If possible, prefer #request_marketo and #request_sales.
  #
  # :call-seq:
  #   request(options)
  def request(options = {})
    source = options.fetch(:source) { :MKTOWS }
    leads = MarketoAPI.array(options.delete(:leads)) +
      MarketoAPI.array(options.delete(:lead))
    if leads.empty?
      raise ArgumentError, ':lead or :leads must be provided'
    end

    valid_id = options.has_key?(:campaign_id) ||
      options.has_key?(:campaign_name) || options.has_key?(:program_name)
    unless valid_id
      raise ArgumentError,
        ':campaign_id, :campaign_name, or :program_name must be provided'
    end

    if tokens = options.delete(:program_tokens) && !options[:program_name]
      raise KeyError,
        ':program_name must be provided when using :program_tokens'
    end

    call(
      :request_campaign,
      options.merge(
        source:              resolve_source(source),
        lead_list:           transform_param_list(:get, leads),
        program_token_list:  tokens
      ).delete_if(&MarketoAPI::MINIMIZE_HASH)
    )
  end

  ##
  # :method: request_marketo
  #
  # Implements +getCampaignsForSource+ for the +marketo+ source; a
  # specialization of #request.
  #
  # :call-seq:
  #   request_marketo(options)

  ##
  # :method: request_sales
  #
  # Implements +getCampaignsForSource+ for the +sales+ source; a
  # specialization of #request.
  #
  # :call-seq:
  #   request_sales(options)

  # Implements
  # {+scheduleCampaign+}[http://developers.marketo.com/documentation/soap/schedulecampaign/].
  #
  # === Optional Parameters
  #
  # +campaign_run_at+:: The time to run the scheduled campaign.
  # +program_tokens+::  An array of program tokens in the form:
  #                     <tt>{ attrib: { name: name, value: value } }</tt>
  #                     This will be made easier to manage in the future.
  #
  # +source+ must be +marketo+ or +sales+ or the equivalent enumerated
  # values from the SOAP environment (+MKTOWS+ or +SALES+).
  #
  # :call-seq:
  #   schedule(program_name, campaign_name, options = {})
  def schedule(program_name, campaign_name, options = {})
    call(
      :schedule_campaign,
      {
        program_name: program_name,
        campaign_name: campaign_name,
        campaign_run_at: options[:campaign_run_at],
        program_token_list: options[:program_tokens]
      }.delete_if(&MarketoAPI::MINIMIZE_HASH)
    )
  end

  SOURCES.each_pair { |name, enum|
    define_method(:"for_#{name}") do |name = nil, exact_name = nil|
      for_source(enum, name, exact_name)
    end

    define_method(:"request_#{name}") do |options = {}|
      request(options.merge(source: name))
    end
  }

  private
  def resolve_source(source)
    source = source.to_sym
    res = if ENUMS.include? source
            source
          else
            SOURCES[source]
          end
    raise ArgumentError, "Invalid source #{source}" unless res
    res
  end
end
