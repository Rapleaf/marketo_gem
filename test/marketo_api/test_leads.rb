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
          id: key[:leadKey][:keyValue].to_i,
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
    lead_key = { leadKey: { keyType: 'id', keyValue: 416 } }
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

  def test_named_getters
    MarketoAPI::Lead::NAMED_KEYS.each_pair do |name, key|
      method = :"get_by_#{name}"
      assert subject.respond_to? method

      stub_specialized :get do
        assert_equal key, subject.send(method, 42).first
      end
    end
  end

  def test_get_type_and_value
    MarketoAPI::Lead::NAMED_KEYS.each_pair do |name, key|
      subject.stub :call, GET_LEAD_STUB do
        lead_key = MarketoAPI::Lead.key(name, 416)
        lead = subject.get(name, 416)
        assert_instance_of MarketoAPI::Lead, lead
        assert_equal 416, lead.id
        assert_equal :get_lead, lead[:Method]
        assert_equal lead_key, lead[:LeadKey]

        lead_key = MarketoAPI::Lead.key(key, 416)
        lead = subject.get(key, 416)
        assert_instance_of MarketoAPI::Lead, lead
        assert_equal 416, lead.id
        assert_equal :get_lead, lead[:Method]
        assert_equal lead_key, lead[:LeadKey]
      end
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

        method, params = subject.sync(lead)
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
          dedupEnabled:   true,
          leadRecordList: lead_list
        }

        method, params = subject.sync_multiple(leads)
        assert_equal :sync_multiple_leads, method
        assert_equal result, params
      end
    end
  end
end
