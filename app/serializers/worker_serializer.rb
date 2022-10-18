class WorkerSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :qr_code
end
