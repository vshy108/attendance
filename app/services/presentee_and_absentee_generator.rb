class PresenteeAndAbsenteeGenerator < ApplicationService
  attr_reader :params
  include TimeHandler
  include HashHandler
  include Pagy::Backend

  def initialize(params)
    @params = params
  end

  def call
    # search on today if no punch_times_punched_datetime_gteq in @params[:q]
    @params[:q] = add_default_value(@params[:q], "punch_times_punched_datetime_gteq", today.to_s)
    @params[:q] = add_ransack_value(
      @params[:q],
      "punch_times_punched_datetime_lt",
      (@params[:q][:punch_times_punched_datetime_gteq].to_date + 1.day).strftime('%F')
    )
    # variable string
    @date_string = @params[:q][:punch_times_punched_datetime_gteq]
    @today_string = today.to_s
    # search
    @q_worker = Worker.ransack(@params[:q])
    # search result
    q_worker_result = @q_worker.result.order(:name)

    # not included workers
    worker_arel = Worker.arel_table
    @other_workers = if @params.dig(:q)&.dig(:name_cont).blank?
                       Worker.where.not(id: q_worker_result)
                     else
                       Worker.where.not(id: q_worker_result)
                             .where(worker_arel[:name].lower.matches("%#{@params[:q][:name_cont].downcase}%"))
                     end

    # NOTE: working in rails s but failed test
    # ransack_worker = q_worker_result.includes(:punch_times).joins(:punch_times).select(
    #   'workers.*', 'punch_times.punched_datetime', 'punch_times.id'
    # ).order('punch_times.punched_datetime')
    ransack_worker = q_worker_result.includes(:punch_times).joins(:punch_times)

    # pagination
    @pagy, workers_pagy = pagy(ransack_worker)
    # view model
    @workers = workers_pagy.collect { |x| TodayAttendanceDecorator.new(x) }
    [@date_string, @today_string, @q_worker, @other_workers, @pagy, @workers]
  end
end
