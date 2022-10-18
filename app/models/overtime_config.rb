class OvertimeConfig < ApplicationRecord
  belongs_to :working_template

  enum overtime_type: { disabled: 'disabled', direct_after_off_work: 'direct_after_off_work', more_than_minimum: 'more_than_minimum', both: 'both' }
end
