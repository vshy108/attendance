class RepeatTemplateWorkingTemplateChanger < ApplicationService
  include RepeatTemplateHandler
  attr_reader :repeat_template
  attr_reader :assigning

  def initialize(repeat_template, assigning = true)
    @repeat_template = repeat_template
    @assigning = assigning
  end

  def call
    earliest_first_repeat_date = obtain_earliest_for_one_repeat_template(@repeat_template)
    worker = @repeat_template.worker
    wd = WorkingDay.arel_table
    related_working_days = worker.working_days.where(wd[:working_date].gteq(earliest_first_repeat_date))
    related_working_days.each do |rwd|
      working_date = rwd.working_date
      repeat_working_template = obtain_working_template_of_repeat_template(worker, working_date)
      next if repeat_working_template.nil?

      default_working_template = worker.default_template.working_template
      next if repeat_working_template == default_working_template

      if @assigning
        rwd.update(working_template: repeat_working_template) if rwd.working_template == default_working_template
      elsif rwd.working_template == repeat_working_template
        rwd.update(working_template: default_working_template)
      end
    end
  end
end
