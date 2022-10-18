require 'test_helper'

class HashHandlerLibTest < ActiveSupport::TestCase
  include HashHandler

  test "should create new hash to contain default value even if the hash is nil" do
    hash = add_default_value(nil, 'a', 1)
    assert_equal 1, hash[:a]
  end

  test "should not overwrite value if the key has non empty value" do
    hash = add_default_value({ a: 2 }, 'a', 1)
    assert_equal 2, hash[:a]
  end

  test "should overwrite value if the key has empty value" do
    hash = add_default_value({ a: '' }, 'a', '1')
    assert_equal '1', hash[:a]
  end
end
