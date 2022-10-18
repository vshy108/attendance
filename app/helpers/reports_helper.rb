module ReportsHelper
  def render_report_dashboard(waiting_process_count, context)
    if waiting_process_count.zero?
      context.render(partial: "/reports/real_dashboard")
    else
      @waiting_process_count = waiting_process_count
      context.render(partial: "/reports/confirm_processing")
    end
  end

  def render_abnormal_working_days(abnormal_working_day_ids_length, context)
    if abnormal_working_day_ids_length.zero?
      context.render(partial: "/application/nil")
    else
      @abnormal_working_day_ids_length = abnormal_working_day_ids_length
      context.render(partial: "/reports/abnormal_working_days")
    end
  end

  def render_report(daily_monthly, worker_reports, dates_header_string, context)
    @worker_reports = worker_reports
    if daily_monthly == 'Daily'
      context.render(partial: "/reports/daily_report")
    else
      @dates_header_string = dates_header_string
      context.render(partial: "/reports/monthly_report")
    end
  end

  def render_daily_report_tr(worker_report, context)
    @worker_report = worker_report
    if worker_report[:no_attendance]
      context.render(partial: "/reports/no_attendance_daily")
    else
      working_day_id = @worker_report[:working_day_id]
      odd_number_punch_time = @worker_report[:odd_number_punch_time]
      @odd_link = if working_day_id
                    if odd_number_punch_time
                      link_to('Yes', working_day_path(id: working_day_id), style: "color: purple !important;")
                    else
                      link_to('-', working_day_path(id: working_day_id))
                    end
                  elsif odd_number_punch_time
                    'Yes'
                  else
                    '-'
                  end
      context.render(partial: "/reports/has_attendance_daily")
    end
  end

  def render_content_tag_month_table(working_day_id, class_name, content_string)
    if working_day_id.nil?
      content_tag(:td, content_string, class: class_name)
    else
      content_tag(:td, content_tag(:a, content_string, href: working_day_path(id: working_day_id)), class: class_name)
    end
  end

  def render_month_table_content(report_hash, working_day_id)
    working_minutes = report_hash[:working_minutes] || 0
    overtime_in_mins = report_hash[:overtime_in_mins] || 0
    hours_value = minutes_to_hhmm(working_minutes + overtime_in_mins)
    if report_hash[:odd_number_punch_time]
      render_content_tag_month_table(working_day_id, "monthly-odd", 'P')
    elsif report_hash[:late_flag] && report_hash[:overtime_in_mins].positive?
      render_content_tag_month_table(working_day_id, "monthly-late monthly-ot", hours_value)
    elsif report_hash[:late_flag]
      render_content_tag_month_table(working_day_id, "monthly-late", hours_value)
    elsif report_hash[:overtime_in_mins].positive?
      render_content_tag_month_table(working_day_id, "monthly-ot", hours_value)
    elsif report_hash[:no_attendance]
      render_content_tag_month_table(working_day_id, "monthly-absence", '-')
    else
      render_content_tag_month_table(working_day_id, "monthly-normal", hours_value)
    end
  end

  def weekday_short_string(start_date_wday, index)
    Date::DAYNAMES[(start_date_wday + index) % 7][0, 2]
  end
end
