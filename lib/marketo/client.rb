require File.expand_path('authentication_header', File.dirname(__FILE__))

module Grabcad
  module Marketo
    def self.create_client (access_key, secret_key, endpoint_uri, wsdl_uri = nil)
      savon_client = Savon.client do
        endpoint endpoint_uri
        if wsdl_uri
          wsdl wsdl_uri
        else
          #default to Marketo API version 2.1 with cached WSDL
          wsdl File.expand_path('../wsdl/marketo_2_1.wsdl', File.dirname(__FILE__))
        end
        read_timeout 90
        open_timeout 90
        headers  ({ "Connection" => "Keep-Alive" })
        log_level :debug
        log false
        pretty_print_xml true
      end
      Client.new(savon_client, Grabcad::Marketo::AuthenticationHeader.new(access_key, secret_key))
    end

    # Based on the WSDL for Marketo API V2.1, cached locally in ../wsdl/marketo_2_1.wsdl.  
    # To select another version of the API, specify the URI to the WSDL as the optional 4th argument to create_client.
    # You will need to verify that the gem still functions properly against the new version of the API.
    #
    # Usage:
    #
    # client = Grabcad::Marketo.create_client(<access_key>, <secret_key>, <endpoint URI>, [<wsdl URI>])
    #
    # == get a lead by email:
    #
    # lead_record = client.get_lead_by_email('example@email.com')
    #
    # puts lead_record.idnum
    #
    # puts lead_record.get_attribute('FirstName')
    #
    # puts lead_record.get_attribute('LastName')
    #
    # == insert/update a new lead: (upsert_lead)
    #
    # lead_record = client.upsert_lead('new_example@email.com', 'Test', 'Lead', 'Initech')
    #
    # == update fields: (update with custom fields)
    #
    # lead_record = client.get_lead_by_email('example@email.com')
    #
    # lead_record.set_attribute('FirstName', 'NewFirst')
    #
    # lead_record.set_attribute('LastName', 'NewLast')
    #
    # lead_record.set_attribute('Email', 'updated@email.com')
    #
    # lead_record.set_attribute('Company', 'Initech2')
    #
    # lead_record.set_attribute(<custom>, <value>)
    #
    # lead.sync
    #
    class Client
      # This constructor is used internally, create your client with *Grabcad::Marketo.create_client(<access_key>, <secret_key>, <endpoint>)*
      def initialize(savon_client, authentication_header)
        @client = savon_client
        @header = authentication_header

        if ENV["RAILS_ENV"] && Rails && Rails.logger
          logger=Rails.logger
        else
          logger=Logger.new(STDOUT)
        end
        @client.globals.log true
      end

      public

      def get_lead_by_lead_id(lead_id)
        get_lead(LeadKey.new(LeadKeyType::IDNUM, lead_id))
      end


      def get_lead_by_email(email)
        get_lead(LeadKey.new(LeadKeyType::EMAIL, email))
      end

      def logger=(logger) #Specify a logger compatible with ruby logger
        @logger = logger
        @client.globals.logger logger
        HTTPI.logger = logger
      end

      def log_level=(level)
        if (level.kind_of? (Fixnum))
          @logger.level = level if @logger
          symbolic_level =  case level
          when Logger::DEBUG
            :debug
          when Logger::INFO
            :info
          when Logger::WARN
            :warn
          when Logger::ERROR
            :error
          else 
            :fatal
          end
          @client.globals.log_level symbolic_level
          HTTPI.log_level = symbolic_level
        else 
          false
        end
      end

      # create (if new) or update (if existing) a lead
      #
      # * email - email address of lead
      # * first - first name of lead
      # * last - surname/last name of lead
      # * company - company the lead is associated with
      #
      # returns the LeadRecord instance on success otherwise nil
      def upsert_lead(email, first, last, company, lead_id = nil)
        lead_record = LeadRecord.new(self, email, lead_id)
        lead_record.set_attribute('FirstName', first)
        lead_record.set_attribute('LastName', last)
        lead_record.set_attribute('Email', email)
        lead_record.set_attribute('Company', company)
        lead_record.sync
      end

      def sync_lead_record_by_email(lead_record)
        raise 'Email not set - Cannot sync lead record without email' if lead_record.email.nil?

        begin
          attributes = []
          lead_record.each_attribute_pair do |name, value|
            attributes << {:attr_name => name, :attr_type => 'string', :attr_value => value}
          end

          response = send_request(:sync_lead, {
            :return_lead => true,
            :lead_record => {
              :email               => lead_record.email,
              :lead_attribute_list => { :attribute => attributes } 
            }
          })
          response[:success_sync_lead][:result][:lead_record]
        rescue Exception => e
          log_exception e
          nil
        end
      end

      def sync_lead_record_by_id(lead_record)
        raise 'ID not set - Cannot sync lead record without ID' if lead_record.id.nil?

        begin
          attributes = []
          lead_record.each_attribute_pair do |name, value|
              attributes << {:attr_name => name, :attr_type => 'string', :attr_value => value}
          end

          attributes << {:attr_name => 'Id', :attr_type => 'string', :attr_value => lead_record.id.to_s}

          response = send_request(:sync_lead, {
            :return_lead => true,
            :lead_record => {
              :lead_attribute_list => { :attribute => attributes },
              :id => lead_record.id
            }
          })
          response[:success_sync_lead][:result][:lead_record]
        rescue Exception => e
          log_exception e
          nil
        end
      end

      #Returns true if the operation succeeded, false otherwise
      def add_to_list(list_id, lead)
        list_operation(list_id_key(list_id), ListOperationType::ADD_TO, lead.id)[:success_list_operation][:result][:success]
      end

      #Returns true if the operation succeeded, false otherwise
      def remove_from_list(list_id, lead)
        list_operation(list_id_key(list_id), ListOperationType::REMOVE_FROM, lead.id)[:success_list_operation][:result][:success]
      end

      #Returns true if the operation succeeded, false otherwise
      def is_member_of_list?(list_id, lead)
        list_operation(list_id_key(list_id), ListOperationType::IS_MEMBER_OF, lead.id)[:success_list_operation][:result][:status_list][:lead_status][:status]
      end

      def enable_soap_debugging
        @client.pretty_print_xml = true
      end

      def log_exception(exp)
        if @logger 
          @logger.warn(exp)
          @logger.warn(exp.backtrace)
        end
      end

      # private
      def list_operation(list_key, list_operation_type, id)
      begin
          response = send_request(:list_operation, {
              :list_operation   => list_operation_type,
              :list_key         => list_key.to_hash,
              :strict           => 'false',
              :list_member_list => {
                  :lead_key => [
                      {:key_type => LeadKeyType::IDNUM, :key_value => id}
                  ]
              }
          })
          return response
        rescue Exception => e
          log_exception e
          return nil
        end
      end

      def list_id_key(list_id)
        ListKey.new(ListKeyType::MKTOLISTNAME, list_id)
      end

      private

      def get_lead(lead_key)
        begin
          response = send_request(:get_lead, {:lead_key => lead_key.to_hash})
          LeadRecord.from_hash(self, response[:success_get_lead][:result][:lead_record_list][:lead_record])
        rescue Exception => e
          log_exception e
          nil
        end
      end

      def send_request(operation, body)
        @header.set_time(DateTime.now)
        response = request(operation, body, @header.to_hash)
        response.body
      end

      def request(operation, body, header)  #returns a Savon 2 response
        auth_header = {"tns:AuthenticationHeader" => header.to_hash}
        # set the marketo-specific authentication header with authentication SHA1
        @client.globals.soap_header(auth_header)
        @client.call(operation, message: body)
      end
    end
  end
end