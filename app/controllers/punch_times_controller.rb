class PunchTimesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_punch_time, only: %i[show edit update destroy edit_uncertain_working_day update_uncertain_working_day]
  before_action :set_workers, only: %i[new edit create update]
  before_action :set_today_string, only: %i[new edit create update]
  include TimeHandler
  include PunchTimeHandler
  include WorkingDayHandler
  include DefaultTemplateHandler
  include RepeatTemplateHandler
  include WorkingTemplateHandler

  # GET /punch_times
  def index
    filter_month_date = begin
                          params[:query]&.to_date || today
                        rescue ArgumentError
                          today
                        end
    @query = filter_month_date.strftime("%m/%Y")
    @month_string = filter_month_date.strftime("%B %Y")
    @current_month_value = today.strftime("%m/%Y")
    @all_workers_punch_times = []
    Worker.all.each do |worker|
      @all_workers_punch_times << {
        name: worker.name,
        daily_attendances: DailyAttendanceCreator.call(worker, filter_month_date)
      }
    end
  end

  # GET /punch_times/1
  def show
  end

  # GET /punch_times/new
  def new
    @punch_time = PunchTime.new
  end

  # GET /punch_times/1/edit
  def edit
  end

  # POST /punch_times
  def create
    @punch_time = PunchTime.new
    validation_result = CreatePunchTimeValidator::Schema.call(punch_time_params.to_h)
    if validation_result.success?
      @punch_time.attributes = validation_result.output
      @punch_time.save
      redirect_to @punch_time, notice: 'Punch time was successfully created.'
    else
      @errors = validation_result.messages(full: true)
      @punch_time = PunchTime.new(punch_time_params)
      render :new
    end
  end

  # PATCH/PUT /punch_times/1
  def update
    validation_result = UpdatePunchTimeValidator::Schema.with(record: @punch_time).call(punch_time_params.to_h)
    if validation_result.success?
      # NOTE: reset the working_day_id and uncertain_working_day_id
      validation_result.output[:working_day_id] = nil
      validation_result.output[:uncertain_working_day_id] = nil
      @punch_time.update(validation_result.output)
      redirect_to @punch_time, notice: 'Punch time was successfully updated.'
    else
      @errors = validation_result.messages(full: true)
      render :edit
    end
  end

  # DELETE /punch_times/1
  def destroy
    @punch_time.destroy
    respond_to do |format|
      format.html { redirect_to punch_times_url, notice: 'Punch time was successfully destroyed.' }
      format.json { render json: {}, status: :ok }
    end
  end

  def edit_uncertain_working_day
    @options = obtain_options_for_working_day_change(@punch_time)
    @working_day_id = params[:working_day_id]
    @current_option = WorkingDay.find_by(id: @working_day_id).working_date.to_s
  end

  def update_uncertain_working_day
    uncertain_working_day = params[:uncertain_working_day]
    @options = obtain_options_for_working_day_change(@punch_time)
    if @options.include? uncertain_working_day
      # NOTE: it might be same day
      original_working_day = @punch_time.uncertain_working_day
      original_working_date = original_working_day&.working_date
      update_working_date = uncertain_working_day.to_date
      if original_working_date == update_working_date
        redirect_to WorkingDay.find(params[:working_day_id]), notice: 'Punch time is updated.'
        return
      end
      worker = @punch_time.worker
      existing_working_day = worker.working_days.find_by(working_date: uncertain_working_day.to_date)
      # the new pointed working day does not exist, hence need to create one
      if existing_working_day.nil?
        working_template_of_repeat_template = obtain_working_template_of_repeat_template(worker, uncertain_working_day)
        working_day = if working_template_of_repeat_template.present?
                        worker.working_days.create(working_template: working_template_of_repeat_template, working_date: uncertain_working_day)
                      else
                        worker.working_days.create(working_template: worker.default_template, working_date: uncertain_working_day)
                      end
        @punch_time.uncertain_working_day = working_day
      else
        @punch_time.uncertain_working_day = existing_working_day
        punched_datetime = @punch_time.punched_datetime
        pt = PunchTime.arel_table
        # NOTE: reassign uncertain_working_day for other punch times
        if original_working_date > update_working_date
          # original_working_date lteq the punch time should belongs to update_working_date
          waiting_change_uncertain_punch_times = original_working_day.uncertain_punch_times.where(
            pt[:punched_datetime].lteq(punched_datetime)
          )
          if waiting_change_uncertain_punch_times.any?
            waiting_change_uncertain_punch_times.each do |wcupt|
              wcupt.uncertain_working_day = existing_working_day
              wcupt.save
            end
          end
        else
          # original_working_date gteq the punch time should belongs to update_working_date
          waiting_change_uncertain_punch_times = original_working_day.uncertain_punch_times.where(
            pt[:punched_datetime].gteq(punched_datetime)
          )
          if waiting_change_uncertain_punch_times.any?
            waiting_change_uncertain_punch_times.each do |wcupt|
              wcupt.uncertain_working_day = existing_working_day
              wcupt.save
            end
          end
        end
      end
      if @punch_time.save
        redirect_to WorkingDay.find(params[:working_day_id]), notice: 'Punch time is updated.'
        return
      end
    end
    render :edit_uncertain_working_day, notice: 'Working day option is prohibited.'
  end

  def new_punch_time_for_working_day
    @working_day_id = params[:working_day_id]
    working_day = WorkingDay.find_by(id: @working_day_id)
    redirect_to abnormal_working_days_path unless working_day.presence
    working_date = working_day.working_date
    @working_date_string = working_date.to_s
    worker = working_day.worker
    @worker_name = worker.name
    @previous_day = working_date - 1.day
    @next_day = working_date + 1.day
    previous_working_day = worker.working_days.find_by(working_date: @previous_day).presence
    next_working_day = worker.working_days.find_by(working_date: @next_day).presence
    if previous_working_day.nil?
      previous_working_template_of_repeat_template = obtain_working_template_of_repeat_template(worker, @previous_day)
      if previous_working_template_of_repeat_template.present?
        @start = @previous_day.beginning_of_day + obtain_working_template_last_to(previous_working_template_of_repeat_template).minute + 1.minute
      else
        @start = @previous_day.beginning_of_day + obtain_default_template_last_to(worker.default_template).minute + 1.minute
      end
    else
      @start = @previous_day.beginning_of_day + obtain_last_to(previous_working_day).minute + 1.minute
    end
    if next_working_day.nil?
      next_working_template_of_repeat_template = obtain_working_template_of_repeat_template(worker, @next_day)
      if next_working_template_of_repeat_template.present?
        @end = @next_day.beginning_of_day + obtain_working_template_first_from(next_working_template_of_repeat_template).minute - 1.minute
      else
        @end = @next_day.beginning_of_day + obtain_default_template_first_from(worker.default_template).minute - 1.minute
      end
    else
      @end = @next_day.beginning_of_day + obtain_first_from(next_working_day).minute - 1.minute
    end
  end

  def create_punch_time_for_working_day
    @working_day_id = params[:working_day_id]
    working_day = WorkingDay.find_by(id: @working_day_id)
    redirect_to abnormal_working_days_path unless working_day.presence
    start_time = params[:start].presence
    end_time = params[:end].presence
    punched_datetime = params[:punched_datetime].presence
    worker = working_day.worker
    if start_time && punched_datetime && end_time &&
       start_time.in_time_zone <= punched_datetime.in_time_zone &&
       punched_datetime.in_time_zone <= end_time.in_time_zone
      punched_datetime_converted = punched_datetime.in_time_zone
      if worker.punch_times.where(
        punched_datetime: punched_datetime.in_time_zone.change(sec: 0)
      ).lazy.any?
        @errors = { invalid: [ "Duplicate punch time" ] }
        working_date = working_day.working_date
        @working_date_string = working_date.to_s
        @worker_name = worker.name
        @previous_day = working_date - 1.day
        @next_day = working_date + 1.day
        @start = start_time.in_time_zone
        @end = end_time.in_time_zone
        render :new_punch_time_for_working_day
        return
      end
      working_date = working_day.working_date
      first_from = working_date.beginning_of_day + obtain_first_from(working_day).minute
      last_to = working_date.beginning_of_day + obtain_last_to(working_day).minute
      if punched_datetime_converted < first_from || punched_datetime_converted > last_to
        working_day.uncertain_punch_times.create(worker: working_day.worker, punched_datetime: punched_datetime)
      else
        working_day.punch_times.create(worker: working_day.worker, punched_datetime: punched_datetime)
      end
      redirect_to working_day, notice: 'Punch Time is created for this working day'
    else
      @errors = { invalid: [ "Beware of the range allowed" ] }
      working_date = working_day.working_date
      @working_date_string = working_date.to_s
      @worker_name = worker.name
      @previous_day = working_date - 1.day
      @next_day = working_date + 1.day
      @start = start_time.in_time_zone
      @end = end_time.in_time_zone
      render :new_punch_time_for_working_day
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_punch_time
    @punch_time = PunchTime.find(params[:id])
  end

  def set_workers
    @workers = Worker.all
  end

  def set_today_string
    @today_string = today.to_s
  end

  # Only allow a trusted parameter "white list" through.
  def punch_time_params
    params.require(:punch_time).permit(:punched_datetime, :worker_id)
  end
end
