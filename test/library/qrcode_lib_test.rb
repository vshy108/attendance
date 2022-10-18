require 'test_helper'

class QrcodeLibTest < ActiveSupport::TestCase
  include Qrcode

  test "should decode same result for what encoded" do
    random_number = rand(1...1e9).to_i
    encoded = encode(random_number)
    decoded = decode(encoded)
    assert_equal random_number, decoded
  end
end
