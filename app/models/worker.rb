class Worker < ApplicationRecord
  has_many :punch_times, dependent: :destroy
  has_many :working_days, dependent: :destroy
  has_many :year_leave_limits, dependent: :destroy
  has_one :default_template, dependent: :destroy
  has_one :repeat_template, dependent: :destroy
  include Qrcode

  def qr_code
    encode(id)
  end
end
