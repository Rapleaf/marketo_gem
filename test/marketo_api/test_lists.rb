require "minitest_helper"

class TestMarketoAPILists < Minitest::Test
  include MarketoTestHelper

  def setup
    super
    @subject = @client.lists
  end

  def test_add
    stub_specialized :list_operation do
      assert_equal :ADDTOLIST, subject.add(:list_key).first
    end
    stub_soap_call do
      result = {
        list_operation:   :ADDTOLIST,
        list_key:         :list_key,
        strict:           false,
        list_member_list: [ lead_key(416) ]
      }

      method, options = subject.add(:list_key, lead: lead_key(416))
      assert_equal :list_operation, method
      assert_equal result, options
    end
  end

  def test_add_no_leads
    assert_raises(ArgumentError) { subject.add(:list_key) }
  end

  def test_add_merged_leads
    stub_soap_call do
      result = {
        list_operation:   :ADDTOLIST,
        list_key:         :list_key,
        strict:           false,
        list_member_list: [ lead_key(905), lead_key(416) ]
      }

      method, options = subject.add(:list_key, leads: lead_key(905),
                                    lead: lead_key(416))
      assert_equal :list_operation, method
      assert_equal result, options
    end
  end

  def test_remove
    stub_specialized :list_operation do
      assert_equal :REMOVEFROMLIST, subject.remove(:list_key).first
    end
    stub_soap_call do
      result = {
        list_operation:   :REMOVEFROMLIST,
        list_key:         :list_key,
        strict:           false,
        list_member_list: [ lead_key(416) ]
      }

      method, options = subject.remove(:list_key, lead: lead_key(416))
      assert_equal :list_operation, method
      assert_equal result, options
    end
  end

  def test_member_q
    stub_specialized :list_operation do
      assert_equal :ISMEMBEROFLIST, subject.member?(:list_key).first
    end
    stub_soap_call do
      result = {
        list_operation:   :ISMEMBEROFLIST,
        list_key:         :list_key,
        strict:           false,
        list_member_list: [ lead_key(416) ]
      }

      method, options = subject.member?(:list_key, lead: lead_key(416))
      assert_equal :list_operation, method
      assert_equal result, options
    end
  end

  def test_class_key
    subject.class::NAMED_TYPES.each { |k, v|
      result = { list_key: { key_type: v, key_value: 'value' } }

      assert_equal result, subject.class.key(k, 'value')
      assert_equal result, subject.class.key(v, 'value')
    }

    assert_raises(ArgumentError) { subject.class.key('invalid', 'value') }
  end
end
