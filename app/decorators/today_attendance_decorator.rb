class TodayAttendanceDecorator
  delegate :name, to: :worker
  delegate :id, to: :worker

  def initialize(worker)
    @worker = worker
  end

  def specified_day_punch_times
    if !@worker.punch_times.nil?
      punch_times = @worker.punch_times.collect { |x| { value: x.punched_datetime&.strftime('%R'), id: x.id } }
      punch_times.sort_by { |pt| pt[:value] }
    else
      []
    end
  end

  private

  attr_reader :worker
end
