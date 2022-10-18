# RailsSettings Model
class Setting < RailsSettings::Base
  field :min_punch_diff_minutes, type: :integer, default: 1
end
