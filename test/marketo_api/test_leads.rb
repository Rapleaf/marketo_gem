require "minitest_helper"

class TestMarketoAPILeads < Minitest::Test
  include MarketoTestHelper

  def setup
    super
    @subject = @client.leads
  end

  def test_get_invalid_lead_key_hash
    assert_raises(ArgumentError) { subject.get({}) }
  end

  GET_LEAD_STUB = ->(method, key) {
    {
      lead_record_list: {
        lead_record: {
          id: key[:lead_key][:key_value].to_i,
          lead_attribute_list: {
            attribute: [
              { attr_name: 'Email', attr_value: nil, attr_type: 'string' },
              { attr_name: 'Method', attr_value: method, attr_type: 'string' },
              { attr_name: 'LeadKey', attr_value: key, attr_type: 'string' }
            ]
          }
        }
      }
    }
  }

  def test_get_valid_lead_key
    lead_key = { lead_key: { key_type: 'id', key_value: 416 } }
    subject.stub :call, GET_LEAD_STUB do
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_lead
    search_lead = MarketoAPI::Lead.new(id: 416)
    lead_key = search_lead.params_for_get
    subject.stub :call, GET_LEAD_STUB do
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_type_and_value
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_id
    assert subject.respond_to? :get_by_id
    stub_specialized :get do
      assert_equal :IDNUM, subject.get_by_id(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_cookie
    assert subject.respond_to? :get_by_cookie
    stub_specialized :get do
      assert_equal :COOKIE, subject.get_by_cookie(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('cookie', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_email
    assert subject.respond_to? :get_by_email
    stub_specialized :get do
      assert_equal :EMAIL, subject.get_by_email(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('email', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_lead_owner_email
    assert subject.respond_to? :get_by_lead_owner_email
    stub_specialized :get do
      assert_equal :LEADOWNEREMAIL,
        subject.get_by_lead_owner_email(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('lead_owner_email', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_salesforce_account_id
    assert subject.respond_to? :get_by_salesforce_account_id
    stub_specialized :get do
      assert_equal :SFDCACCOUNTID,
        subject.get_by_salesforce_account_id(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('salesforce_account_id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_salesforce_contact_id
    assert subject.respond_to? :get_by_salesforce_contact_id
    stub_specialized :get do
      assert_equal :SFDCCONTACTID,
        subject.get_by_salesforce_contact_id(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('salesforce_contact_id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_salesforce_lead_id
    assert subject.respond_to? :get_by_salesforce_lead_id
    stub_specialized :get do
      assert_equal :SFDCLEADID,
        subject.get_by_salesforce_lead_id(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('salesforce_lead_id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_salesforce_lead_owner_id
    assert subject.respond_to? :get_by_salesforce_lead_owner_id
    stub_specialized :get do
      assert_equal :SFDCLEADOWNERID,
        subject.get_by_salesforce_lead_owner_id(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('salesforce_lead_owner_id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  def test_get_by_salesforce_opportunity_id
    assert subject.respond_to? :get_by_salesforce_opportunity_id
    stub_specialized :get do
      assert_equal :SFDCOPPTYID,
        subject.get_by_salesforce_opportunity_id(42).first
    end
    subject.stub :call, GET_LEAD_STUB do
      lead_key = MarketoAPI::Lead.key('salesforce_opportunity_id', 416)
      lead = subject.get(lead_key)
      assert_instance_of MarketoAPI::Lead, lead
      assert_equal 416, lead.id
      assert_equal :get_lead, lead[:Method]
      assert_equal lead_key, lead[:LeadKey]
    end
  end

  EMPTY_LEAD_HASH = {
    lead_record: {
      lead_attribute_list: {
        attribute: []
      }
    }
  }

  def test_sync
    subject.stub :extract_from_response, ARGS_STUB, EMPTY_LEAD_HASH do
      stub_soap_call do
        hash = GET_LEAD_STUB[:sync_lead, lead_key(416)]
        lead = MarketoAPI::Lead.
          from_soap_hash(hash[:lead_record_list][:lead_record])

        result = subject.send(:transform_param, :sync, lead)

        method, params = subject.sync(lead).first
        assert_equal :sync_lead, method
        assert_equal result, params
      end
    end
  end

  def test_sync_multiple
    subject.stub :extract_from_response, ARGS_STUB, [] do
      stub_soap_call do
        hashes = [
          GET_LEAD_STUB[:sync_multiple_leads, lead_key(416)],
          GET_LEAD_STUB[:sync_multiple_leads, lead_key(905)],
        ]
        leads = hashes.map { |hash|
          MarketoAPI::Lead.
            from_soap_hash(hash[:lead_record_list][:lead_record])
        }
        lead_list = subject.send(:transform_param_list, :sync, leads)
        result = {
          dedup_enabled: true,
          lead_record_list: lead_list
        }

        method, params = subject.sync_multiple(leads).first
        assert_equal :sync_multiple_leads, method
        assert_equal result, params
      end
    end
  end
end
