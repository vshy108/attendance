require 'test_helper'

class WorkerTest < ActiveSupport::TestCase
  test "has qr_code after save" do
    worker = Worker.new(name: 'a')
    worker.save
    worker.reload
    assert_equal worker.qr_code, "FW#{worker.id.to_s.rjust(6, '0')}"
  end
end
