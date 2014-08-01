require "minitest_helper"

class TestMarketoAPILead < Minitest::Test
  include MarketoTestHelper

  def setup
    super
    @id = 99
    @date = DateTime.new(2014, 01, 01)
    @email = 'great@gretzky.com'
    @attributes = {
      String:  'string',
      Int: 5,
      Date:    @date
    }
    @subject = MarketoAPI::Lead.new(id: @id, email: @email) do |lead|
      @attributes.each { |k, v| lead[k] = v }
    end
  end

  def test_id
    assert_equal 99, subject.id
  end

  def test_cookie
    assert_nil subject.cookie
    subject.cookie = 'cookie'
    refute_nil subject.cookie
    assert_equal 'cookie', subject.cookie
  end

  def test_attributes
    assert_equal @attributes.merge(Email: @email), subject.attributes
  end

  def test_types
    types = Hash[*@attributes.merge(Email: @email).map { |(k, v)|
      [ k, subject.send(:infer_value_type, v) ]
    }.flatten]
    assert_equal types, subject.types
  end

  def test_proxy_bad_assignment
    assert_raises(ArgumentError) { subject.proxy = :invalid }
  end

  def test_proxy_leads_assignment
    assert_same @client.leads, subject.proxy = @client.leads
  end

  def test_proxy_proxy_assignment
    subject.proxy = @client.campaigns
    assert_same @client.leads, subject.proxy
  end

  def test_proxy_client_assignment
    subject.proxy = @client
    assert_same @client.leads, subject.proxy
  end

  def test_forwarded_methods
    [
      :[], :each, :each_pair, :each_key, :each_value, :keys, :values
    ].each do |m|
      assert subject.respond_to? m
    end
  end

  def test_index_assignment
    subject[:Test] = 33
    assert subject.attributes.has_key? :Test
    assert subject.types.has_key? :Test
    assert_equal 33, subject.attributes[:Test]
    assert_equal 'integer', subject.types[:Test]
  end

  def test_foreign
    assert_equal({ type: :id, id: 3 }, subject.foreign('id', 3))
  end

  def test_sync_no_proxy
    assert_raises(ArgumentError) { subject.sync }
    assert_raises(ArgumentError) { subject.sync! }
  end

  def test_sync_with_proxy
    @client.leads.stub :sync, ->(lead) { lead.dup } do
      subject.proxy = @client.leads
      assert_equal subject, subject.sync
      refute_same subject, subject.sync
    end
  end

  def test_sync_bang_failed
    @client.leads.stub :sync, ->(lead) { nil } do
      subject.proxy = @client.leads
      assert_nil subject.sync!
    end
  end

  def test_sync_bang_success
    @client.leads.stub :sync, ->(lead) { lead.dup } do
      subject.proxy = @client.leads
      assert_same subject, subject.sync!
    end
  end

  def test_params_for_get
    assert_equal MarketoAPI::Lead.key(:IDNUM, @id), subject.params_for_get
  end

  def test_params_for_sync
    result = {
      returnLead: true,
      leadRecord: {
        Email: @email,
        Id: @id,
        leadAttributeList: {
          attribute: [
            { attrName: 'Email', attrType: 'string', attrValue: @email },
            { attrName: 'String', attrType: 'string', attrValue: 'string' },
            { attrName: 'Int', attrType: 'integer', attrValue: 5 },
            { attrName: 'Date', attrType: 'datetime', attrValue: @date }
          ]
        }
      }
    }

    assert_equal result, subject.params_for_sync
  end

  def test_class_key
    subject.class::NAMED_KEYS.each { |k, v|
      result = { leadKey: { keyType: v, keyValue: 'value' } }

      assert_equal result, subject.class.key(k, 'value')
      assert_equal result, subject.class.key(v, 'value')
    }

    assert_raises(ArgumentError) { subject.class.key('invalid', 'value') }
  end

  def test_class_from_soap_hash
    hash = {
      id: @id.to_s,
      email: @email,
      lead_attribute_list: {
        attribute: [
          { attr_name: 'Email', attr_type: 'string', attr_value: @email },
          { attr_name: 'String', attr_type: 'string', attr_value: 'string' },
          { attr_name: 'Int', attr_type: 'integer', attr_value: 5 },
          { attr_name: 'Date', attr_type: 'datetime', attr_value: @date }
        ]
      }
    }
    assert_equal subject, subject.class.from_soap_hash(hash)
  end
end
