class WorkingDaysController < ApplicationController
  include PunchTimeHandler
  before_action :authenticate_user!
  before_action :set_working_day, only: %i[show]

  def show
    @working_template = @working_day.working_template
    @valid_work_sections = @working_template.valid_work_sections
    @punch_times = @working_day.punch_times.or(@working_day.uncertain_punch_times).order(:punched_datetime)
    @worker_report = DailyReportCreator.call(@working_day.worker, @working_day.working_date)
    @overtime_value = @working_day.worker.overtime_value

    @working_day_status = if @worker_report[:odd_number_punch_time]
                            '(Odd times of punchings)'
                          elsif @worker_report[:late_flag] && @worker_report[:overtime_in_mins] >= 30
                            '(OT but late)'
                          elsif @worker_report[:late_flag]
                            '(Late)'
                          elsif @worker_report[:overtime_in_mins] >= 30
                            '(OT)'
                          elsif @worker_report[:no_attendance]
                            '(Absent)'
                          else
                            '(Normal)'
                          end
  end

  def abnormal_working_days
    @abnormal_working_days_hash = obtain_abnormal_working_days_hash
    abnormal_working_day_ids = @abnormal_working_days_hash.keys
    @abnormal_working_day_ids_length = abnormal_working_day_ids.length
    @pagy, @abnormal_working_days = pagy(WorkingDay.where(id: abnormal_working_day_ids).includes(:worker))
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_working_day
    @working_day = WorkingDay.find(params[:id])
  end
end
