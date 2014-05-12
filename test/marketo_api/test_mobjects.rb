require 'minitest_helper'

class TestMarketoAPIMObjects < Minitest::Test
  include MarketoTestHelper

  def setup
    super
    @subject = @client.mobjects
  end

  def test_delete_no_args
    assert_raises(ArgumentError) {
      subject.delete
    }
  end

  def test_delete_bad_type
    assert_raises(ArgumentError) {
      subject.delete(MarketoAPI::MObject.program)
    }
  end

  def test_delete_no_id
    assert_raises(ArgumentError) {
      subject.delete(MarketoAPI::MObject.opportunity)
    }
  end

  def test_delete
    subject.stub :extract_mobject_status_list, ARGS_STUB do
      stub_soap_call do
        source = MarketoAPI::MObject.opportunity(3)
        method, params = subject.delete(source)
        assert_equal :delete_m_objects, method
        assert_equal({ mObjectList: [ source.params_for_delete ] }, params)
      end
    end

    extractor = ->(*args) {
      {
        m_obj_status_list: args.last[:mObjectList].map { |mobject|
          {
            m_object_status: { id: mobject[:id], status: 'DELETED' }
          }
        }
      }
    }

    subject.stub :call, extractor do
      source = MarketoAPI::MObject.opportunity(3)
      result = subject.delete(source)
      assert_equal({ source.id => 'DELETED' }, result)
    end
  end

  def test_list
    subject.stub :extract_from_response, ARGS_STUB do
      stub_soap_call do
        method, _ = subject.list.first
        assert_equal :list_m_objects, method
      end
    end

    list = ->(*args) {
      { objects: MarketoAPI::MObject::ALL_TYPES.map(&:to_s) }
    }
    subject.stub :call, list do
      assert_equal MarketoAPI::MObject::ALL_TYPES.map(&:to_s),
        subject.list
    end
  end

  def test_describe_bad_type
    assert_raises(ArgumentError) {
      subject.describe(:foo)
    }
  end

  def test_describe
    subject.stub :extract_from_response, ARGS_STUB do
      stub_soap_call do
        method, params = subject.describe('Opportunity')
        assert_equal :describe_m_object, method
        assert_equal({ objectName: 'Opportunity' }, params)
      end
    end

    output = ->(*args) {
      { metadata: 'description' }
    }
    subject.stub :call, output do
      assert_equal 'description', subject.describe('Opportunity')
    end
  end

  def test_get_bad_type
    assert_raises(ArgumentError) {
      subject.get(MarketoAPI::MObject.activityrecord)
    }
  end

  def test_get
    MarketoAPI::MObjects::Get.stub :new, ARGS_STUB do
      stub_soap_call do
        method, params = subject.get(MarketoAPI::MObject.opportunity)
        assert_equal :get_m_objects, method
        assert_equal({ type: :Opportunity, includeDetails: false }, params)
      end
    end
  end

  def test_get_object
    object = {
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

    response = MarketoAPI::MObjects::Get.new(
      return_count:         1,
      has_more:             true,
      new_stream_position:  'you are here',
      m_object_list:        [ { m_object: object } ]
    )

    expected = MarketoAPI::MObject.opportunity(99) do |mobject|
      { String: 'string', Int: 5, }.each { |k, v|
        mobject.attributes[k] = v
      }
      { Tag: { String: 'string', Int: 5 } }.each { |k, v|
        mobject.types[k] = v
      }
    end

    assert_equal 1, response.return_count
    assert_equal 'you are here', response.stream_position
    assert_equal [ expected ], response.mobjects
    assert response.more?
  end
end
