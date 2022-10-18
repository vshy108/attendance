class RepeatTemplatePart < ApplicationRecord
  belongs_to :repeat_template
  belongs_to :working_template
end
