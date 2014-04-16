require 'minitest_helper'

class TestMarketoAPIMObject < Minitest::Test
  include MarketoTestHelper

  def setup
    super
    @id = 99
    @attributes = {
      String:  'string',
      Int:     5,
    }
    @types = {
      Tag: {
        String: 'string',
        Int:    5
      }
    }
    @subject = MarketoAPI::MObject.new(:Opportunity, @id) do |lead|
      @attributes.each { |k, v| lead.attributes[k] = v }
      @types.each { |k, v| lead.types[k] = v }
    end
  end

  def test_type
    assert_equal :Opportunity, subject.type
  end

  def test_initialization
    MarketoAPI::MObject::ALL_TYPES.each do |type|
      assert_equal type, MarketoAPI::MObject.new(type).type
      assert_equal type, MarketoAPI::MObject.send(type.downcase).type
    end

    assert_raises(ArgumentError) {
      MarketoAPI::MObject.new(:UnknownType)
    }
  end

  def test_id
    assert_equal 99, subject.id
    subject.id = 33
    assert_equal 33, subject.id
  end

  def test_include_details
    refute subject.include_details
    subject.include_details = true
    assert subject.include_details
  end

  def test_attributes
    assert_equal @attributes, subject.attributes
  end

  def test_types
    local = MarketoAPI::MObject.opportunity
    assert_equal({}, local.types)
    local.types[:Tag]
    assert_equal({ Tag: {} }, local.types)
  end

  def test_criteria_empty
    assert_empty subject.criteria
  end

  def test_criteria_correct_name_translation
    MarketoAPI::MObject::Criteria::TYPES.each do |k, v|
      c = subject.criteria(k, 'value', :eq).last
      assert_same v, c.name
      c = subject.criteria(c.name.dup, 'value', :eq).last
      assert_same v, c.name
    end
  end

  def test_criteria_correct_comparison
    MarketoAPI::MObject::Criteria::CMP.each do |cmp|
      c = subject.criteria(:name, 'value', cmp).last
      assert_equal cmp, c.comparison
      c = subject.criteria(:name, 'value', cmp.downcase).last
      assert_equal cmp, c.comparison
    end

    assert_raises(ArgumentError) {
      subject.criteria(:foo, 'value', :xx)
    }
  end

  def test_criteria_bad_params
    assert_raises(ArgumentError) {
      subject.criteria(:foo, 'value', :eq)
    }
    assert_raises(ArgumentError) {
      subject.criteria(:name)
    }
    assert_raises(ArgumentError) {
      subject.criteria(:name, 'value')
    }
  end

  def test_criteria_hash
    MarketoAPI::MObject::Criteria::TYPES.each do |k, v|
      MarketoAPI::MObject::Criteria::CMP.each do |cmp|
        c = subject.criteria(k, 'value', cmp).last
        e = {
          attr_name:  v,
          attr_value: 'value',
          comparison: cmp
        }

        assert_equal e, c.to_h
      end
    end
  end

  def test_association_empty
    assert_empty subject.associations
  end

  def test_association_correct_name_translation
    MarketoAPI::MObject::Association::TYPES.each do |k|
      c = subject.association(k, id: 1).last
      assert_same k, c.type
      c = subject.association(k.downcase, id: 1).last
      assert_same k, c.type
    end
  end

  def test_association_bad_params
    assert_raises(ArgumentError) {
      subject.association(:foo, id: 2)
    }
    assert_raises(KeyError) {
      subject.association(:lead)
    }
  end

  def test_association_options
    z = ->(options) { subject.association(:lead, options).last }

    c = z.call(id: 1)
    assert_equal 1, c.id
    assert_nil c.external

    c = z.call(external: 1)
    assert_nil c.id
    assert_equal 1, c.external_key

    c = z.call(id: 1, external_key: 2)
    assert_equal 1, c.id
    assert_equal 2, c.external
  end

  def test_association_hash
    MarketoAPI::MObject::Association::TYPES.each do |k|
      c = subject.association(k, id: 3, external: 4).last
      e = {
        m_obj_type:   k,
        id:           3,
        external_key: 4
      }

      assert_equal e, c.to_h
    end
  end

  def test_params_for_delete_invalid_type
    assert_raises(ArgumentError) {
      MarketoAPI::MObject.program(32).params_for_delete
    }
  end

  def test_params_for_delete_missing_id
    assert_raises(ArgumentError) {
      MarketoAPI::MObject.opportunity.params_for_delete
    }
  end

  def test_params_for_delete
    assert_equal({ type: subject.type, id: subject.id },
                 subject.params_for_delete)
  end

  def test_params_for_get_invalid_type
    assert_raises(ArgumentError) {
      MarketoAPI::MObject.activityrecord.params_for_get
    }
  end

  def test_params_for_get
    assert_equal({
      type: subject.type, id: subject.id, include_details: false
    }, subject.params_for_get)
  end

  def test_params_for_get_minimal
    subject.id = nil
    assert_equal({
      type: subject.type, include_details: false
    }, subject.params_for_get)
  end

  def test_params_for_get_with_details
    subject.include_details = true
    assert_equal({
      type: subject.type, id: subject.id, include_details: true
    }, subject.params_for_get)
  end

  def test_params_for_get_with_stream_position
    subject.stream_position = 'position'
    assert_equal({
      type: subject.type, id: subject.id, include_details: false,
      stream_position: 'position'
    }, subject.params_for_get)
  end

  def test_params_for_get_with_criteria
    subject.criteria(:name, 'value', :eq)
    assert_equal({
      type: subject.type, id: subject.id, include_details: false,
      m_obj_criteria_list: [
        {
          attr_name:  'Name',
          attr_value: 'value',
          comparison: :EQ
        }
      ]
    }, subject.params_for_get)
  end

  def test_params_for_get_with_association
    subject.association(:Lead, id: 3, external: 4)
    assert_equal({
      type: subject.type, id: subject.id, include_details: false,
      m_obj_association_list: [
        {
          m_obj_type:   :Lead,
          id:           3,
          external_key: 4
        }
      ]
    }, subject.params_for_get)
  end

  def test_class_from_soap_hash
    hash = {
      type: :Opportunity,
      id:   99,
      attrib_list: {
        attrib: [
          { name: 'String', value: 'string' },
          { name: 'Int', value: 5 },
        ]
      },
      type_attrib_list: {
        type_attrib: [
          {
            attr_type: 'Tag',
            attr_list: {
              attrib: [
                { name: 'String', value: 'string' },
                { name: 'Int', value: 5 },
              ]
            }
          }
        ]
      }
    }

    assert_equal subject, MarketoAPI::MObject.from_soap_hash(hash)
  end
end
