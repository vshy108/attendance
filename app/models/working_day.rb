class WorkingDay < ApplicationRecord
  belongs_to :working_template
  belongs_to :worker
  has_many :punch_times, class_name: 'PunchTime', foreign_key: 'working_day_id',
                         dependent: :nullify, inverse_of: 'working_day'
  has_many :uncertain_punch_times, class_name: 'PunchTime', foreign_key: 'uncertain_working_day_id',
                                   dependent: :nullify, inverse_of: 'uncertain_working_day'
end
