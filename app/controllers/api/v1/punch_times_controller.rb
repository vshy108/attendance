class Api::V1::PunchTimesController < Api::V1::ApplicationController
  before_action :authenticate_user!
  include Qrcode
  include TimeHandler
  include PunchTimeHandler
  include Pagination
  include Pagy::Backend

  def create
    qr_code = punch_time_params[:qr_code]
    render(json: { errors: ["Missing input"] }, status: :unprocessable_entity) unless qr_code
    id = decode(qr_code)
    worker = Worker.find_by(id: id)
    if worker
      if worker_has_punch_times_within?(worker, current_datetime)
        min_punch_diff_minutes = Setting.min_punch_diff_minutes
        render(json: { errors: ["Please scan after #{min_punch_diff_minutes} #{'minute'.pluralize(min_punch_diff_minutes)}"] }, status: :unprocessable_entity)
        return
      end
      punch_time = worker.punch_times.create(punched_datetime: current_datetime, worker: worker)
      # NOTE: need `spring stop` to reload the serializer for test
      render(json: PunchTimeSerializer.new(punch_time, include: [:worker]), status: :ok)
    else
      render(json: { errors: ["Invalid input"] }, status: :unprocessable_entity)
    end
  end

  def history
    assign_limit(params[:limit])
    begin
      @pagy, punch_times = pagy(PunchTime.all.reversed.includes(:worker))
      options = {
        links: generate_link(@pagy),
        include: [:worker]
      }
      render(json: PunchTimeSerializer.new(punch_times, options), status: :ok)
    rescue Pagy::OverflowError
      render(json: PunchTimeSerializer.new(PunchTime.none), status: :ok)
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def punch_time_params
    params.require(:punch_time).permit(:qr_code)
  end
end
