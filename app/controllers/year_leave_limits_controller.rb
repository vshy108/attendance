class YearLeaveLimitsController < ApplicationController
  before_action :set_year_leave_limit, only: %i[show edit update destroy]
  before_action :set_workers, only: %i[new edit create update]
  before_action :authenticate_user!

  # GET /year_leave_limits
  def index
    @search = YearLeaveLimit.ransack(params[:q])
    ransack_year_leave_limits = @search.result(distinct: true)
    @pagy, @year_leave_limits = pagy(ransack_year_leave_limits.includes(:worker).order(id: :desc))
  end

  # GET /year_leave_limits/1
  def show
  end

  # GET /year_leave_limits/new
  def new
    @year_leave_limit = YearLeaveLimit.new
  end

  # GET /year_leave_limits/1/edit
  def edit
  end

  # POST /year_leave_limits
  def create
    @year_leave_limit = YearLeaveLimit.new
    validation_result = CreateYearLeaveLimitValidator::Schema.call(year_leave_limit_params.to_h)
    if validation_result.success?
      @year_leave_limit.attributes = validation_result.output
      @year_leave_limit.save
      redirect_to @year_leave_limit, notice: 'Year leave limit was successfully created.'
    else
      @errors = validation_result.messages(full: true)
      @year_leave_limit = YearLeaveLimit.new(year_leave_limit_params)
      render :new
    end
  end

  # PATCH/PUT /year_leave_limits/1
  def update
    validation_result = UpdateYearLeaveLimitValidator::Schema.with(
      record: @year_leave_limit
    ).call(year_leave_limit_params.to_h)
    if validation_result.success?
      @year_leave_limit.update(validation_result.output)
      redirect_to @year_leave_limit, notice: 'Year leave limit was successfully updated.'
    else
      @errors = validation_result.messages(full: true)
      render :edit
    end
  end

  # DELETE /year_leave_limits/1
  def destroy
    @year_leave_limit.destroy
    redirect_to year_leave_limits_url, notice: 'Year leave limit was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_year_leave_limit
    @year_leave_limit = YearLeaveLimit.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def year_leave_limit_params
    params.require(:year_leave_limit).permit(:year_number, :allowed_annual_days_total, :worker_id)
  end

  def set_workers
    @workers = Worker.all
  end
end
