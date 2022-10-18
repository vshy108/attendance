class PunchTimeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :punched_datetime
  belongs_to :worker
end
