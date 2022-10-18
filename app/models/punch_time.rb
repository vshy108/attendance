class PunchTime < ApplicationRecord
  belongs_to :worker
  belongs_to :working_day, class_name: 'WorkingDay', foreign_key: :working_day_id,
                           inverse_of: 'punch_times', optional: true
  belongs_to :uncertain_working_day, class_name: 'WorkingDay', foreign_key: :uncertain_working_day_id,
                                     inverse_of: 'uncertain_punch_times', optional: true

  before_save :truncate_seconds

  scope :reversed, -> { order 'punched_datetime DESC' }

  def truncate_seconds
    # zero out seconds
    self.punched_datetime = punched_datetime.change(sec: 0)
  end
end
