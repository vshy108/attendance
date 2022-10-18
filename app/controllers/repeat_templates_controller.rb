class RepeatTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_repeat_template, only: %i[show edit update destroy]
  before_action :set_workers_and_today_and_working_templates, only: %i[new create edit update]
  include TimeHandler
  include RepeatTemplateHandler

  # GET /repeat_templates
  def index
    @search = RepeatTemplate.ransack(params[:q])
    ransack_repeat_templates = @search.result(distinct: true)
    @pagy, @repeat_templates = pagy(ransack_repeat_templates.includes(:worker).order(id: :desc))
  end

  # GET /repeat_templates/1
  def show
    @repeat_template_parts = @repeat_template.repeat_template_parts.order(:first_repeat_date).includes(:working_template)
  end

  # GET /repeat_templates/new
  def new
    @repeat_template = RepeatTemplate.new
  end

  # GET /repeat_templates/1/edit
  def edit
  end

  # POST /repeat_templates
  def create
    @repeat_template = RepeatTemplate.new
    dup_repeat_template_params = repeat_template_params.to_h
    if dup_repeat_template_params[:repeat_template_parts_attributes]
      dup_repeat_template_params[:repeat_template_parts_attributes] = dup_repeat_template_params[:repeat_template_parts_attributes].values.map(&:to_h)
    end
    validation_result = CreateRepeatTemplateValidator::Schema.call(dup_repeat_template_params)
    if validation_result.success?
      @repeat_template.attributes = validation_result.output
      @repeat_template.save
      RepeatTemplateWorkingTemplateChanger.call(@repeat_template, true)
      earliest_first_repeat_date = obtain_earliest_for_one_repeat_template(@repeat_template)
      WorkingDayPunchTimesNoEndCleaner.call(@repeat_template.worker, earliest_first_repeat_date)
      redirect_to @repeat_template, notice: 'Repeat template was successfully created.'
    else
      @errors = validation_result.messages(full: true)
      if @errors[:repeat_template_parts_attributes]&.is_a?(Hash)
        nested_error_hash = @errors[:repeat_template_parts_attributes]&.values&.flatten&.reduce({}, :merge)
        @errors = @errors.except(:repeat_template_parts_attributes).merge(nested_error_hash)
      end
      @repeat_template = RepeatTemplate.new(repeat_template_params)
      render :new
    end
  end

  # PATCH/PUT /repeat_templates/1
  def update
    dup_repeat_template_params = repeat_template_params.to_h
    if dup_repeat_template_params[:repeat_template_parts_attributes]
      dup_repeat_template_params[:repeat_template_parts_attributes] = dup_repeat_template_params[:repeat_template_parts_attributes].values.map(&:to_h)
    end
    validation_result = UpdateRepeatTemplateValidator::Schema
                        .with(record: @repeat_template)
                        .call(dup_repeat_template_params.to_h)
    if validation_result.success?
      RepeatTemplateWorkingTemplateChanger.call(@repeat_template, false)
      old_earliest_repeat_date = obtain_earliest_for_one_repeat_template(@repeat_template)
      @repeat_template.update(validation_result.output)
      @repeat_template.reload
      RepeatTemplateWorkingTemplateChanger.call(@repeat_template, true)
      new_earliest_repeat_date = obtain_earliest_for_one_repeat_template(@repeat_template)
      if old_earliest_repeat_date < new_earliest_repeat_date
        WorkingDayPunchTimesNoEndCleaner.call(@repeat_template.worker, old_earliest_repeat_date)
      else
        WorkingDayPunchTimesNoEndCleaner.call(@repeat_template.worker, new_earliest_repeat_date)
      end
      redirect_to @repeat_template, notice: 'Repeat Template was successfully updated.'
    else
      @errors = validation_result.messages(full: true)
      if @errors[:repeat_template_parts_attributes]&.is_a?(Hash)
        nested_error_hash = @errors[:repeat_template_parts_attributes]&.values&.flatten&.reduce({}, :merge)
        @errors = @errors.except(:repeat_template_parts_attributes).merge(nested_error_hash)
      end
      render :edit
    end
  end

  # DELETE /repeat_templates/1
  def destroy
    earliest_repeat_date = obtain_earliest_for_one_repeat_template(@repeat_template)
    worker = @repeat_template.worker
    RepeatTemplateWorkingTemplateChanger.call(@repeat_template, false)
    @repeat_template.destroy
    WorkingDayPunchTimesNoEndCleaner.call(worker, earliest_repeat_date)
    redirect_to repeat_templates_url, notice: 'Repeat template was successfully destroyed.'
  end

  private

  def set_repeat_template
    @repeat_template = RepeatTemplate.find(params[:id])
  end

  def repeat_template_params
    params.require(:repeat_template).permit(
      :repeat_day_difference,
      :worker_id,
      repeat_template_parts_attributes: %i[id first_repeat_date working_template_id _destroy]
    )
  end

  def set_workers_and_today_and_working_templates
    @workers = Worker.all
    @today_string = today.to_s
    @working_templates = WorkingTemplate.all
  end
end
