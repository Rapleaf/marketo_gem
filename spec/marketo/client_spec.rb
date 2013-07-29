require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'savon/mock/spec_helper'

module Grabcad
  module Marketo
    describe Client do
      include Savon::SpecHelper
      # since the test does not specify a local WSDL, it will exhibit the behavior defined here https://github.com/savonrb/savon/issues/396

      EMAIL = "some@email.com"
      IDNUM = 12345
      FIRST = 'Test'
      LAST = 'Lead'
      COMPANY = 'Initech'
      MOBILE = '415 123 456'

      ACCESS_KEY = 'ACCESS_KEY'
      SECRET_KEY = 'SECRET_KEY'
      ENDPOINT = "mock_endpoint"

      TEST_LIST = "TestList"

      before(:all) { savon.mock! }
      after(:all)  { savon.unmock! }
      
      it "should return a marketo client" do
        client = Grabcad::Marketo.create_client(ACCESS_KEY, SECRET_KEY, ENDPOINT)
        client.should_not be_nil;
      end

      it "should get a lead by email" do
        fixture = File.read("spec/fixtures/get_lead_response.xml")
        savon.expects(:get_lead).with(message:  {:lead_key=>{:key_type=>"EMAIL", :key_value=>EMAIL}} ).returns(fixture)

        marketo = Grabcad::Marketo.create_client(ACCESS_KEY, SECRET_KEY, ENDPOINT)
        marketo.logger=(Logger.new(STDOUT))
        marketo.log_level = Logger::DEBUG
        lead = marketo.get_lead_by_email(EMAIL)
        lead.should_not be_nil
        lead.email.should == EMAIL
      end

      it "should get a lead by id" do
        fixture = File.read("spec/fixtures/get_lead_response.xml")
        savon.expects(:get_lead).with(message:  {:lead_key=>{:key_type=>"IDNUM", :key_value=>IDNUM}} ).returns(fixture)

        marketo = Grabcad::Marketo.create_client(ACCESS_KEY, SECRET_KEY, ENDPOINT)
        marketo.logger=(Logger.new(STDOUT))
        marketo.log_level = Logger::DEBUG
        lead = marketo.get_lead_by_lead_id(IDNUM)
        lead.should_not be_nil
        lead.id.should == IDNUM
      end

      it "should create a new lead" do
        fixture = File.read("spec/fixtures/insert_lead_response.xml")
        savon.expects(:sync_lead).with(message:  {:return_lead=>true,
         :lead_record=>
         {:email=>"some@email.com",
           :lead_attribute_list=>
           {:attribute=>
            [{:attr_name=>"Email",
              :attr_type=>"string",
              :attr_value=>EMAIL},
              {:attr_name=>"FirstName", :attr_type=>"string", :attr_value=>FIRST},
              {:attr_name=>"LastName", :attr_type=>"string", :attr_value=>LAST},
              {:attr_name=>"Company",
                :attr_type=>"string",
                :attr_value=>COMPANY}]}}} ).returns(fixture)
        marketo = Grabcad::Marketo.create_client(ACCESS_KEY, SECRET_KEY, ENDPOINT)
        marketo.logger=(Logger.new(STDOUT))
        marketo.log_level = Logger::DEBUG
        lead = marketo.upsert_lead(EMAIL, FIRST, LAST, COMPANY)
        lead.get_attribute("FirstName").should == FIRST
        lead.email.should == EMAIL
        lead.get_attribute("LastName").should == LAST
        lead.get_attribute("Company").should == COMPANY
        lead.id.should == IDNUM
      end

      describe "given a lead" do
        before(:all) do
          fixture = File.read("spec/fixtures/get_lead_response.xml")
          savon.expects(:get_lead).with(message:  {:lead_key=>{:key_type=>"IDNUM", :key_value=>IDNUM}} ).returns(fixture)

          @marketo = Grabcad::Marketo.create_client(ACCESS_KEY, SECRET_KEY, ENDPOINT)
          @marketo.logger=(Logger.new(STDOUT))
          @marketo.log_level = Logger::DEBUG
          @lead = @marketo.get_lead_by_lead_id(IDNUM)
        end

        it "should check if a lead is a member of a list and return false" do
          fixture = File.read("spec/fixtures/is_lead_in_list_false.xml")
          savon.expects(:list_operation).with(message: 
            {:list_operation=>"ISMEMBEROFLIST",
              :list_key=>{:key_type=>"MKTOLISTNAME", 
                          :key_value=>TEST_LIST},
              :strict=>"false",
              :list_member_list=>{:lead_key=>[{:key_type=>"IDNUM", :key_value=>IDNUM}]}}).returns(fixture)

          @marketo.is_member_of_list?( TEST_LIST, @lead).should be false
        end

        it "should check if a lead is a member of a list and return true" do
          fixture = File.read("spec/fixtures/is_lead_in_list_true.xml")
          savon.expects(:list_operation).with(message: 
            {:list_operation=>"ISMEMBEROFLIST",
              :list_key=>{:key_type=>"MKTOLISTNAME", 
                          :key_value=>TEST_LIST},
              :strict=>"false",
              :list_member_list=>{:lead_key=>[{:key_type=>"IDNUM", :key_value=>IDNUM}]}}).returns(fixture)

          @marketo.is_member_of_list?( TEST_LIST, @lead).should be true
        end

        it "should add a lead to a list" do
          fixture = File.read("spec/fixtures/add_lead_to_list.xml")
          savon.expects(:list_operation).with(message: 
            {:list_operation=>"ADDTOLIST",
              :list_key=>{:key_type=>"MKTOLISTNAME", 
                          :key_value=>TEST_LIST},
              :strict=>"false",
              :list_member_list=>{:lead_key=>[{:key_type=>"IDNUM", :key_value=>IDNUM}]}}).returns(fixture)


          @marketo.add_to_list(TEST_LIST, @lead).should be true
        end

        it "should remove a lead from a list" do
          fixture = File.read("spec/fixtures/remove_lead_from_list.xml")
          savon.expects(:list_operation).with(message: 
            {:list_operation=>"REMOVEFROMLIST",
              :list_key=>{:key_type=>"MKTOLISTNAME", 
                          :key_value=>TEST_LIST},
              :strict=>"false",
              :list_member_list=>{:lead_key=>[{:key_type=>"IDNUM", :key_value=>IDNUM}]}}).returns(fixture)

          @marketo.remove_from_list(TEST_LIST, @lead).should be true
        end
      end
    end
  end
end
