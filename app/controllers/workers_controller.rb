class WorkersController < ApplicationController
  include Pagy::Backend
  include TimeHandler
  before_action :authenticate_user!
  before_action :set_worker, only: %i[show edit update destroy]
  before_action :set_working_templates, only: %i[new edit create update]

  # GET /workers
  def index
    # it is not necessary order by id by .all
    @pagy, workers = pagy(Worker.all)
    pt = PunchTime.arel_table
    workers_ids = workers.pluck(:id)
    results = PunchTime.find_by_sql(
      pt.where(pt[:worker_id].in(workers_ids))
        .project(pt[Arel.star]).distinct_on(pt[:worker_id])
        .order(pt[:worker_id], pt[:punched_datetime].desc)
    )
    worker_ids_has_punchtime = results.map(&:worker_id)
    worker_ids_has_no_punchtime = workers_ids - worker_ids_has_punchtime
    results_sort_desc = results.sort_by { |r| r[:punched_datetime] }.reverse!
    @final_results = results_sort_desc.map do |result|
      {
        latest_punch_time: result.punched_datetime.strftime("%I:%M %p"),
        day_hash: day_diff_to_hash((today - result.punched_datetime.to_date).to_i),
        worker: workers.find(result.worker_id)
      }
    end
    worker_ids_has_no_punchtime.each do |wihnp|
      @final_results << { latest_punch_time: nil, day_hash: nil, worker: workers.find(wihnp) }
    end
  end

  # GET /workers/1
  def show
    filter_month_date = begin
                          params[:query]&.to_date || today
                        rescue ArgumentError
                          today
                        end
    @query = filter_month_date.strftime("%m/%Y")
    @month_string = filter_month_date.strftime("%B %Y")
    @current_month_value = today.strftime("%m/%Y")
    @punch_times_daily = DailyAttendanceCreator.call(@worker, filter_month_date)
    @default_template = @worker.default_template&.working_template
    @repeat_template = @worker.repeat_template
  end

  # GET /workers/new
  def new
    @worker = Worker.new
  end

  # GET /workers/1/edit
  def edit
  end

  # POST /workers
  def create
    @worker = Worker.new
    validation_result = WorkerValidator::Schema.call(worker_params.to_h)
    if validation_result.success?
      working_template_id = worker_params[:working_template_id]
      @worker.attributes = validation_result.output.except(:working_template_id)
      Worker.transaction do
        @worker.save
        @worker.create_default_template!(working_template_id: working_template_id)
      end
      redirect_to @worker, notice: 'Worker was successfully created.'
    else
      @worker = Worker.new(validation_result.output.except(:working_template_id))
      @errors = validation_result.messages(full: true)
      render :new
    end
  rescue ActiveRecord::RecordInvalid
    @errors = { record: ["Invalid input, worker's creation is rollback"] }
    render :new
  end

  # PATCH/PUT /workers/1
  def update
    validation_result = WorkerValidator::Schema.call(worker_params.to_h)
    if validation_result.success?
      @worker.update(validation_result.output.except(:working_template_id))
      @worker.default_template.update(working_template_id: worker_params[:working_template_id])
      redirect_to @worker, notice: 'Worker was successfully updated.'
    else
      @errors = validation_result.messages(full: true)
      render :edit
    end
  end

  # DELETE /workers/1
  def destroy
    @worker.destroy
    redirect_to workers_url, notice: 'Worker was successfully destroyed.'
  end

  def qr_code
    worker_id = params[:id]
    worker = Worker.find_by(id: worker_id)
    if worker
      @qr = RQRCode::QRCode.new(worker.qr_code, size: 4, level: :h)
      @worker_name = worker.name
      @qr_code = worker.qr_code
    else
      redirect_to workers_url, notice: 'Invalid worker'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_worker
    @worker = Worker.find(params[:id])
  end

  def set_working_templates
    @working_templates = WorkingTemplate.all
  end

  # Only allow a trusted parameter "white list" through.
  def worker_params
    params.require(:worker).permit(:name, :working_template_id, :overtime_value)
  end
end
