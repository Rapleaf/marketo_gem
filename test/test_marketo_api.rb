require "minitest_helper"

class TestMarketoAPI < Minitest::Test
  def test_self_bad_client
    assert_raises(ArgumentError) {
      MarketoAPI.client
    }
  end

  def test_self_client
    actual = MarketoAPI.client(user_id: 'user', encryption_key: 'key')
    assert_instance_of MarketoAPI::Client, actual
  end

  def test_self_array_hash
    input    = { a: 1 }
    expected = [ input ]
    actual   = MarketoAPI.array(input)
    assert_equal expected, actual
    assert_same expected.first, actual.first
  end

  def test_self_array_array
    input = [ 1 ]
    assert_same input, MarketoAPI.array(input)
  end

  def test_self_array_other
    assert_equal [ 1 ], MarketoAPI.array(1)
  end

  def test_self_freeze
    actual = MarketoAPI.
      freeze(%w(The quick brown fox jumps over the lazy dog.))
    assert actual.frozen?
    assert actual.all?(&:frozen?)
  end
end
