unless User.exists?
  puts "Seed user"
  User.create! username: 'admin', email: 'admin@test.com', name: "Admin Testing",
               password: 'admin123', password_confirmation: 'admin123'
end

unless Rails.env.production?
  unless WorkingTemplate.exists?
    puts "Seed working template"
    WorkingTemplate.create! name: 'Normal', override_working_minutes: 510
    WorkingTemplate.create! name: 'Pray', override_working_minutes: 450
  end

  unless OvertimeConfig.exists?
    puts "Seed overtime config"
    OvertimeConfig.create! working_template: WorkingTemplate.first, overtime_type: OvertimeConfig.overtime_types[:both]
    OvertimeConfig.create! working_template: WorkingTemplate.second, overtime_type: OvertimeConfig.overtime_types[:both]
  end

  unless ValidWorkSection.exists?
    puts "Seed valid work section"
    wt1 = WorkingTemplate.first
    ValidWorkSection.create! from_time_in_minute: 8 * 60 + 30, to_time_in_minute: 13 * 60, working_template: wt1
    ValidWorkSection.create! from_time_in_minute: 14 * 60, to_time_in_minute: 18 * 60, working_template: wt1
    wt2 = WorkingTemplate.second
    ValidWorkSection.create! from_time_in_minute: 8 * 60 + 30, to_time_in_minute: 13 * 60, working_template: wt2
    ValidWorkSection.create! from_time_in_minute: 15 * 60, to_time_in_minute: 18 * 60, working_template: wt2
  end

  unless Worker.exists?
    puts "Seed worker"
    Worker.create! name: "Worker Testing", overtime_value: 10
    Worker.create! name: "Worker Testing2", overtime_value: 11
    Worker.create! name: 'Shameem bin Bandar', overtime_value: 12
    Worker.create! name: 'Maazin bin Abbaas', overtime_value: 13
    Worker.create! name: 'Ishaaq bin Raaji', overtime_value: 14
    Worker.create! name: 'Ismad bin Abdur Raheem', overtime_value: 15
    Worker.create! name: 'Ubaida bin Salmaan', overtime_value: 16
    Worker.create! name: 'Bongsu binti Puteh', overtime_value: 17
    Worker.create! name: "Sa'adong binti Mat", overtime_value: 18
    Worker.create! name: 'Putri binti Kamat', overtime_value: 19
    Worker.create! name: 'Kartika binti Ujang', overtime_value: 20
    Worker.create! name: 'Chahaya binti Sulung', overtime_value: 21
  end

  unless DefaultTemplate.exists?
    puts "Seed default template"
    w1 = Worker.first
    w2 = Worker.second
    w3 = Worker.third
    w4 = Worker.fourth
    w5 = Worker.fifth
    w6 = Worker.offset(5).first
    w7 = Worker.offset(5).second
    w8 = Worker.offset(5).third
    w9 = Worker.offset(5).fourth
    w10 = Worker.offset(5).fifth
    w11 = Worker.offset(10).first
    w12 = Worker.offset(10).second
    wt1 = WorkingTemplate.first
    DefaultTemplate.create! worker: w1, working_template: wt1
    DefaultTemplate.create! worker: w2, working_template: wt1
    DefaultTemplate.create! worker: w3, working_template: wt1
    DefaultTemplate.create! worker: w4, working_template: wt1
    DefaultTemplate.create! worker: w5, working_template: wt1
    DefaultTemplate.create! worker: w6, working_template: wt1
    DefaultTemplate.create! worker: w7, working_template: wt1
    DefaultTemplate.create! worker: w8, working_template: wt1
    DefaultTemplate.create! worker: w9, working_template: wt1
    DefaultTemplate.create! worker: w10, working_template: wt1
    DefaultTemplate.create! worker: w11, working_template: wt1
    DefaultTemplate.create! worker: w12, working_template: wt1
  end

  unless PunchTime.exists?
    puts "Seed punch time"
    w1 = Worker.first
    w2 = Worker.second
    w3 = Worker.third
    w4 = Worker.fourth
    w5 = Worker.fifth
    w6 = Worker.offset(5).first
    w7 = Worker.offset(5).second
    w8 = Worker.offset(5).third
    w9 = Worker.offset(5).fourth
    w10 = Worker.offset(5).fifth
    w11 = Worker.offset(10).first
    w12 = Worker.offset(10).second
    PunchTime.create worker: w1, punched_datetime: "2018-12-01 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-01 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-01 14:10:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-01 19:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-02 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-02 13:03:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-02 14:14:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-02 19:35:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-03 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-03 14:10:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-03 19:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-04 00:00:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-04 05:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-04 06:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-04 14:10:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-04 19:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-05 00:00:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-05 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-05 17:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-06 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-06 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-06 14:10:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-07 14:10:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-07 17:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-08 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-08 17:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-09 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-09 13:02:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-10 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-10 17:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-11 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-11 14:10:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-12 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-12 14:10:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-13 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-13 13:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-13 14:10:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-13 19:30:00"

    PunchTime.create worker: w1, punched_datetime: "2018-12-14 09:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-14 12:02:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-14 14:10:00"
    PunchTime.create worker: w1, punched_datetime: "2018-12-14 17:30:00"

    # ///////////////////////////////////////

    PunchTime.create worker: w2, punched_datetime: "2018-12-01 08:32:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-01 13:00:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-01 14:00:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-01 18:00:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-02 09:02:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-02 12:53:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-02 13:54:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-02 17:35:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-03 09:03:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-03 13:03:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-03 14:13:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-03 17:33:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-04 09:04:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-04 13:04:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-04 14:14:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-04 17:34:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-05 09:05:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-05 13:05:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-05 14:15:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-05 17:35:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-06 09:06:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-06 13:06:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-06 14:16:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-06 17:36:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-07 09:07:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-07 13:07:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-07 14:17:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-07 17:37:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-08 09:08:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-08 13:08:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-08 14:18:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-08 17:38:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-09 09:09:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-09 13:09:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-09 14:19:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-09 17:39:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-10 09:12:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-10 13:13:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-10 14:14:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-10 17:15:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-11 09:22:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-11 13:23:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-11 14:24:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-11 18:25:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-12 09:32:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-12 13:33:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-12 14:34:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-12 17:35:00"

    PunchTime.create worker: w2, punched_datetime: "2018-12-13 09:42:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-13 13:43:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-13 14:44:00"
    PunchTime.create worker: w2, punched_datetime: "2018-12-13 17:45:00"

    PunchTime.create worker: w3, punched_datetime: "2018-12-14 08:32:00"
    PunchTime.create worker: w3, punched_datetime: "2018-12-14 13:01:00"
    PunchTime.create worker: w3, punched_datetime: "2018-12-14 14:02:00"
    PunchTime.create worker: w3, punched_datetime: "2018-12-14 18:03:00"

    PunchTime.create worker: w4, punched_datetime: "2018-12-13 08:32:00"
    PunchTime.create worker: w4, punched_datetime: "2018-12-13 13:01:00"
    PunchTime.create worker: w4, punched_datetime: "2018-12-13 14:02:00"
    PunchTime.create worker: w4, punched_datetime: "2018-12-13 18:03:00"

    PunchTime.create worker: w5, punched_datetime: "2018-12-12 08:32:00"
    PunchTime.create worker: w5, punched_datetime: "2018-12-12 13:01:00"
    PunchTime.create worker: w5, punched_datetime: "2018-12-12 14:02:00"
    PunchTime.create worker: w5, punched_datetime: "2018-12-12 18:03:00"

    PunchTime.create worker: w6, punched_datetime: "2018-12-11 08:32:00"
    PunchTime.create worker: w6, punched_datetime: "2018-12-11 13:01:00"
    PunchTime.create worker: w6, punched_datetime: "2018-12-11 14:02:00"
    PunchTime.create worker: w6, punched_datetime: "2018-12-11 18:03:00"

    PunchTime.create worker: w7, punched_datetime: "2018-12-10 08:32:00"
    PunchTime.create worker: w7, punched_datetime: "2018-12-10 13:01:00"
    PunchTime.create worker: w7, punched_datetime: "2018-12-10 14:02:00"
    PunchTime.create worker: w7, punched_datetime: "2018-12-10 18:03:00"

    PunchTime.create worker: w8, punched_datetime: "2018-12-09 08:32:00"
    PunchTime.create worker: w8, punched_datetime: "2018-12-09 13:01:00"
    PunchTime.create worker: w8, punched_datetime: "2018-12-09 14:02:00"
    PunchTime.create worker: w8, punched_datetime: "2018-12-09 18:03:00"

    PunchTime.create worker: w9, punched_datetime: "2018-12-08 08:32:00"
    PunchTime.create worker: w9, punched_datetime: "2018-12-08 13:01:00"
    PunchTime.create worker: w9, punched_datetime: "2018-12-08 14:02:00"
    PunchTime.create worker: w9, punched_datetime: "2018-12-08 18:03:00"

    PunchTime.create worker: w10, punched_datetime: "2018-12-07 08:32:00"
    PunchTime.create worker: w10, punched_datetime: "2018-12-07 13:01:00"
    PunchTime.create worker: w10, punched_datetime: "2018-12-07 14:02:00"
    PunchTime.create worker: w10, punched_datetime: "2018-12-07 18:03:00"

    PunchTime.create worker: w11, punched_datetime: "2018-12-06 08:32:00"
    PunchTime.create worker: w11, punched_datetime: "2018-12-06 13:01:00"
    PunchTime.create worker: w11, punched_datetime: "2018-12-06 14:02:00"
    PunchTime.create worker: w11, punched_datetime: "2018-12-06 18:03:00"

    PunchTime.create worker: w12, punched_datetime: "2018-12-05 08:32:00"
    PunchTime.create worker: w12, punched_datetime: "2018-12-05 13:01:00"
    PunchTime.create worker: w12, punched_datetime: "2018-12-05 14:02:00"
    PunchTime.create worker: w12, punched_datetime: "2018-12-05 18:03:00"
  end

  unless RepeatTemplate.exists?
    puts "Seed repeat template"
    rt = RepeatTemplate.create! repeat_day_difference: 7, worker: Worker.first
    rt.repeat_template_parts.create! first_repeat_date: "2018-12-01", working_template: WorkingTemplate.where(name: 'Pray').first
  end

  unless YearLeaveLimit.exists?
    puts "Seed year leave limit"
    w1 = Worker.first
    w2 = Worker.second
    w3 = Worker.third
    w4 = Worker.fourth
    w5 = Worker.fifth
    w6 = Worker.offset(5).first
    w7 = Worker.offset(5).second
    w8 = Worker.offset(5).third
    w9 = Worker.offset(5).fourth
    w10 = Worker.offset(5).fifth
    w11 = Worker.offset(10).first
    w12 = Worker.offset(10).second
    workers = [ w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12 ]
    workers.each do |worker|
      YearLeaveLimit.create! year_number: 2019, allowed_annual_days_total: 14, worker: worker
    end
  end

  unless Holiday.exists?
    puts "Seed holiday"
    Holiday.create! valid_date: Time.zone.today, name: 'Today', description: 'Holiday for today'
    Holiday.create! valid_date: Time.zone.tomorrow, name: 'Tomorrow', description: 'Holiday for tomorrow'
  end
end
