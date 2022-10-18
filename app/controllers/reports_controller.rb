class ReportsController < ApplicationController
  include PunchTimeHandler
  include TimeHandler
  include RangeHandler
  before_action :authenticate_user!
  respond_to :json, only: [:process_punch_times]

  def dashboard
    @waiting_process_count = waiting_process_count
    if @waiting_process_count.zero?
      @abnormal_working_day_ids_length = obtain_abnormal_working_days_hash.keys.length
      @options = %w[Daily Monthly]
      @today_string = today.to_s
      @daily_monthly = params[:daily_monthly] || 'Daily'

      @start_date = params[:start_date].presence || @today_string
      @start_date_wday = begin
                           @start_date.to_date.wday
                         rescue ArgumentError
                           today.wday
                         end
      @start_date_weekday = Date::DAYNAMES[@start_date_wday]
      if @daily_monthly == 'Daily'
        @worker_reports = Worker.all.map do |worker_item|
          worker_report = DailyReportCreator.call(worker_item, @start_date)
          worker_report[:qr_code] = worker_item.qr_code
          worker_report[:worker_name] = worker_item.name
          worker_report[:overtime_value] = worker_item.overtime_value
          worker_report[:worker_id] = worker_item.id
          worker_report
        end
      else # Monthly
        @dates_header_string = []
        # if this month got 31 days, then display 31 days
        total_day_this_month = @start_date.to_date.end_of_month.strftime('%d').to_i
        total_day_this_month.times do |n|
          current_loop_date = @start_date.to_date + n.days
          @dates_header_string << current_loop_date.strftime("%d")
        end
        @worker_reports = Worker.all.map do |worker_item|
          start_date_object = @start_date.to_date
          reports = []
          worker_report = {}
          total_working_minutes = 0
          total_late_minutes = 0
          total_ot_minutes = 0
          total_overtime_in_mins_ignore_lateness = 0
          total_day_this_month.times do |n|
            current_loop_date = start_date_object + n.days
            if current_loop_date > tomorrow
              reports << {
                no_attendance: true
              }
            else
              report_object = DailyReportCreator.call(worker_item, current_loop_date.to_s)
              (total_working_minutes += report_object[:working_minutes]) if !report_object[:working_minutes].nil?
              (total_late_minutes += report_object[:late_minutes]) if !report_object[:late_minutes].nil?
              (total_ot_minutes += report_object[:overtime_in_mins]) if !report_object[:overtime_in_mins].nil?
              (total_overtime_in_mins_ignore_lateness += report_object[:overtime_in_mins_ignore_lateness]) if !report_object[:overtime_in_mins_ignore_lateness].nil?
              reports << report_object
            end
          end
          worker_report[:reports] = reports
          worker_report[:qr_code] = worker_item.qr_code
          worker_report[:worker_name] = worker_item.name
          worker_report[:overtime_value] = worker_item.overtime_value
          worker_report[:worker_id] = worker_item.id
          worker_report[:total_working_minutes] = total_working_minutes
          worker_report[:total_late_minutes] = total_late_minutes
          worker_report[:total_ot_minutes] = total_ot_minutes
          worker_report[:total_overtime_in_mins_ignore_lateness] = total_overtime_in_mins_ignore_lateness
          worker_report
        end
      end
    end
  end

  def process_punch_times
    @results = []
    waiting_process_ids.each do |waiting_process_id|
      @results << assign_working_day(waiting_process_id)
    end
    render(json: { results: @results.compact }, status: :ok)
  end
end
