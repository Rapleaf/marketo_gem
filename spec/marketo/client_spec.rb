require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Rapleaf
  module Marketo

    describe Client do
      EMAIL   = "some@email.com"
      IDNUM   = 29
      FIRST   = 'Joe'
      LAST    = 'Smith'
      COMPANY = 'Rapleaf'
      MOBILE  = '415 123 456'
      API_KEY = 'API123KEY'

      context 'Exception handling' do
        it "should return nil if any exception is raised on get_lead request" do
          savon_client          = mock('savon_client').as_null_object
          authentication_header = mock('authentication_header').as_null_object
          client                = Rapleaf::Marketo::Client.new(savon_client, authentication_header)
          savon_client.should_receive(:request).and_raise Exception
          client.get_lead_by_email(EMAIL).should be_nil
        end

        it "should return nil if any exception is raised on sync_lead request" do
          savon_client          = mock('savon_client').as_null_object
          authentication_header = mock('authentication_header').as_null_object
          client                = Rapleaf::Marketo::Client.new(savon_client, authentication_header)
          savon_client.should_receive(:request).and_raise Exception
          client.sync_lead(EMAIL, FIRST, LAST, COMPANY, MOBILE).should be_nil
        end
      end

      context 'Client interaction' do
        it "should have the correct body format on get_lead_by_idnum" do
          savon_client          = mock('savon_client')
          authentication_header = mock('authentication_header')
          client                = Rapleaf::Marketo::Client.new(savon_client, authentication_header)
          response_hash         = {
              :success_get_lead => {
                  :result => {
                      :count            => 1,
                      :lead_record_list => {
                          :lead_record => {
                              :email                 => EMAIL,
                              :lead_attribute_list   => {
                                  :attribute => [
                                      {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                      {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                      {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                      {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                                  ]
                              },
                              :foreign_sys_type      => nil,
                              :foreign_sys_person_id => nil,
                              :id                    => IDNUM.to_s
                          }
                      }
                  }
              }
          }
          expect_request(savon_client,
                         authentication_header,
                         equals_matcher(:lead_key => {
                             :key_value => IDNUM,
                             :key_type  => LeadKeyType::IDNUM
                         }),
                         'ns1:paramsGetLead',
                         response_hash)
          expected_lead_record = LeadRecord.new(EMAIL, IDNUM)
          expected_lead_record.set_attribute('name1', 'val1')
          expected_lead_record.set_attribute('name2', 'val2')
          expected_lead_record.set_attribute('name3', 'val3')
          expected_lead_record.set_attribute('name4', 'val4')
          client.get_lead_by_idnum(IDNUM).should == expected_lead_record
        end

        it "should have the correct body format on get_lead_by_email" do
          savon_client          = mock('savon_client')
          authentication_header = mock('authentication_header')
          client                = Rapleaf::Marketo::Client.new(savon_client, authentication_header)
          response_hash         = {
              :success_get_lead => {
                  :result => {
                      :count            => 1,
                      :lead_record_list => {
                          :lead_record => {
                              :email                 => EMAIL,
                              :lead_attribute_list   => {
                                  :attribute => [
                                      {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                      {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                      {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                      {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                                  ]
                              },
                              :foreign_sys_type      => nil,
                              :foreign_sys_person_id => nil,
                              :id                    => IDNUM.to_s
                          }
                      }
                  }
              }
          }
          expect_request(savon_client,
                         authentication_header,
                         equals_matcher({:lead_key => {
                             :key_value => EMAIL,
                             :key_type  => LeadKeyType::EMAIL}}),
                         'ns1:paramsGetLead',
                         response_hash)
          expected_lead_record = LeadRecord.new(EMAIL, IDNUM)
          expected_lead_record.set_attribute('name1', 'val1')
          expected_lead_record.set_attribute('name2', 'val2')
          expected_lead_record.set_attribute('name3', 'val3')
          expected_lead_record.set_attribute('name4', 'val4')
          client.get_lead_by_email(EMAIL).should == expected_lead_record
        end

        it "should have the correct body format on sync_lead_record" do
          savon_client          = mock('savon_client')
          authentication_header = mock('authentication_header')
          client                = Rapleaf::Marketo::Client.new(savon_client, authentication_header)
          response_hash         = {
              :success_sync_lead => {
                  :result => {
                      :lead_id     => IDNUM,
                      :sync_status => {
                          :error   => nil,
                          :status  => 'UPDATED',
                          :lead_id => IDNUM
                      },
                      :lead_record => {
                          :email                 => EMAIL,
                          :lead_attribute_list   => {
                              :attribute => [
                                  {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                  {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                  {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                  {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                              ]
                          },
                          :foreign_sys_type      => nil,
                          :foreign_sys_person_id => nil,
                          :id                    => IDNUM.to_s
                      }
                  }
              }
          }
          expect_request(savon_client,
                         authentication_header,
                         equals_matcher({
                                            :return_lead => true,
                                            :lead_record => {
                                                :email               => EMAIL,
                                                :lead_attribute_list =>
                                                    {
                                                        :attribute => [
                                                            {:attr_value => "val1",
                                                             :attr_name  => "name1",
                                                             :attr_type  => "string"},
                                                            {:attr_value => "val2",
                                                             :attr_name  => "name2",
                                                             :attr_type  => "string"},
                                                            {:attr_value => EMAIL,
                                                             :attr_name  => "Email",
                                                             :attr_type  => "string"}
                                                        ]}}}),
                         'ns1:paramsSyncLead',
                         response_hash)
          lead_record = LeadRecord.new(EMAIL)
          lead_record.set_attribute('name1', 'val1')
          lead_record.set_attribute('name2', 'val2')

          expected_lead_record = LeadRecord.new(EMAIL, IDNUM)
          expected_lead_record.set_attribute('Email', EMAIL)
          expected_lead_record.set_attribute('name1', 'val1')
          expected_lead_record.set_attribute('name2', 'val2')
          expected_lead_record.set_attribute('name3', 'val3')
          expected_lead_record.set_attribute('name4', 'val4')
          client.sync_lead_record(lead_record).should == expected_lead_record
        end

        it "should have the correct body format on sync_lead" do
          savon_client          = mock('savon_client')
          authentication_header = mock('authentication_header')
          client                = Rapleaf::Marketo::Client.new(savon_client, authentication_header)
          response_hash         = {
              :success_sync_lead => {
                  :result => {
                      :lead_id     => IDNUM,
                      :sync_status => {
                          :error   => nil,
                          :status  => 'UPDATED',
                          :lead_id => IDNUM
                      },
                      :lead_record => {
                          :email                 => EMAIL,
                          :lead_attribute_list   => {
                              :attribute => [
                                  {:attr_name => 'name1', :attr_type => 'string', :attr_value => 'val1'},
                                  {:attr_name => 'name2', :attr_type => 'string', :attr_value => 'val2'},
                                  {:attr_name => 'name3', :attr_type => 'string', :attr_value => 'val3'},
                                  {:attr_name => 'name4', :attr_type => 'string', :attr_value => 'val4'}
                              ]
                          },
                          :foreign_sys_type      => nil,
                          :foreign_sys_person_id => nil,
                          :id                    => IDNUM.to_s
                      }
                  }
              }
          }

          expect_request(savon_client,
                         authentication_header,
                         Proc.new { |actual|
                           actual_attribute_list                                  = actual[:lead_record][:lead_attribute_list][:attribute]
                           actual[:lead_record][:lead_attribute_list][:attribute] = nil
                           expected                                               = {
                               :return_lead => true,
                               :lead_record => {
                                   :email               => "some@email.com",
                                   :lead_attribute_list =>
                                       {
                                           :attribute => nil}}
                           }
                           actual.should == expected
                           actual_attribute_list.should =~ [
                               {:attr_value => FIRST,
                                :attr_name  => "FirstName",
                                :attr_type  => "string"},
                               {:attr_value => LAST,
                                :attr_name  => "LastName",
                                :attr_type  => "string"},
                               {:attr_value => EMAIL,
                                :attr_name  =>"Email",
                                :attr_type  => "string"},
                               {:attr_value => COMPANY,
                                :attr_name  => "Company",
                                :attr_type  => "string"},
                               {:attr_value => MOBILE,
                                :attr_name  => "MobilePhone",
                                :attr_type  => "string"}
                           ]
                         },
                         'ns1:paramsSyncLead',
                         response_hash)
          expected_lead_record = LeadRecord.new(EMAIL, IDNUM)
          expected_lead_record.set_attribute('name1', 'val1')
          expected_lead_record.set_attribute('name2', 'val2')
          expected_lead_record.set_attribute('name3', 'val3')
          expected_lead_record.set_attribute('name4', 'val4')
          client.sync_lead(EMAIL, FIRST, LAST, COMPANY, MOBILE).should == expected_lead_record
        end

        context "list operations" do
          LIST_KEY = 'awesome leads list'

          before(:each) do
            @savon_client          = mock('savon_client')
            @authentication_header = mock('authentication_header')
            @client                = Rapleaf::Marketo::Client.new(@savon_client, @authentication_header)
          end

          it "should have the correct body format on add_to_list" do
            response_hash = {} # TODO
            expect_request(@savon_client,
                           @authentication_header,
                           equals_matcher({
                                              :list_operation   => ListOperationType::ADD_TO,
                                              :list_key         => LIST_KEY,
                                              :strict           => 'false',
                                              :list_member_list => {
                                                  :lead_key => [
                                                      {
                                                          :key_type  => 'EMAIL',
                                                          :key_value => EMAIL
                                                      }
                                                  ]
                                              }
                                          }),
                           'ns1:paramsListOperation',
                           response_hash)

            @client.add_to_list(LIST_KEY, EMAIL).should == response_hash
          end

          it "should have the correct body format on remove_from_list" do
            response_hash = {} # TODO
            expect_request(@savon_client,
                           @authentication_header,
                           equals_matcher({
                                              :list_operation   => ListOperationType::REMOVE_FROM,
                                              :list_key         => LIST_KEY,
                                              :strict           => 'false',
                                              :list_member_list => {
                                                  :lead_key => [
                                                      {
                                                          :key_type  => 'EMAIL',
                                                          :key_value => EMAIL
                                                      }
                                                  ]
                                              }
                                          }),
                           'ns1:paramsListOperation',
                           response_hash)

            @client.remove_from_list(LIST_KEY, EMAIL).should == response_hash
          end

          it "should have the correct body format on is_member_of_list?" do
            response_hash = {} # TODO
            expect_request(@savon_client,
                           @authentication_header,
                           equals_matcher({
                                              :list_operation   => ListOperationType::IS_MEMBER_OF,
                                              :list_key         => LIST_KEY,
                                              :strict           => 'false',
                                              :list_member_list => {
                                                  :lead_key => [
                                                      {
                                                          :key_type  => 'EMAIL',
                                                          :key_value => EMAIL
                                                      }
                                                  ]
                                              }
                                          }),
                           'ns1:paramsListOperation',
                           response_hash)

            @client.is_member_of_list?(LIST_KEY, EMAIL).should == response_hash
          end
        end
      end

      private

      def equals_matcher(expected)
        Proc.new { |actual|
          actual.should == expected
        }
      end

      def expect_request(savon_client, authentication_header, expected_body_matcher, expected_namespace, response_hash)
        header_hash       = stub('header_hash')
        soap_response     = stub('soap_response')
        request_namespace = mock('namespace')
        request_header    = mock('request_header')
        soap_request      = mock('soap_request')
        authentication_header.should_receive(:set_time)
        authentication_header.should_receive(:to_hash).and_return(header_hash)
        request_namespace.should_receive(:[]=).with("xmlns:ns1", "http://www.marketo.com/mktows/")
        request_header.should_receive(:[]=).with("ns1:AuthenticationHeader", header_hash)
        soap_request.should_receive(:namespaces).and_return(request_namespace)
        soap_request.should_receive(:header).and_return(request_header)
        soap_request.should_receive(:body=) do |actual_body|
          expected_body_matcher.call(actual_body)
        end
        soap_response.should_receive(:to_hash).and_return(response_hash)
        savon_client.should_receive(:request).with(expected_namespace).and_yield(soap_request).and_return(soap_response)
      end
    end

    describe ListOperationType do
      it 'should define the correct types' do
        ListOperationType::ADD_TO.should == 'ADDTOLIST'
        ListOperationType::IS_MEMBER_OF.should == 'ISMEMBEROFLIST'
        ListOperationType::REMOVE_FROM.should == 'REMOVEFROMLIST'
      end
    end
  end
end