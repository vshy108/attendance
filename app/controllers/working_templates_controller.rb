class WorkingTemplatesController < ApplicationController
  include Pagy::Backend
  include TimeHandler
  before_action :authenticate_user!
  before_action :set_working_template, only: %i[show edit update destroy edit_working_template_overtime update_working_template_overtime]
  before_action :set_overtime_options, only: %i[new create edit update edit_working_template_overtime update_working_template_overtime]
  before_action :set_total_sections_minutes, only: %i[edit update edit_working_template_overtime update_working_template_overtime]

  def index
    @pagy, working_templates_pagy = pagy(WorkingTemplate.all.order(:id).includes(:default_templates, :working_days, :overtime_config, :repeat_template_parts))
    @working_templates = working_templates_pagy.collect { |x| WorkingTemplatesDecorator.new(x) }
  end

  def show
    @default_templates_owners = @working_template.default_templates.includes(:worker).collect(&:worker)
    @valid_work_sections = @working_template.valid_work_sections
    @overtime_type = @working_template.overtime_config.overtime_type
    @repeat_templates = RepeatTemplatePart.where(working_template_id: @working_template.id).collect(&:repeat_template).uniq
  end

  def new
    @working_template = WorkingTemplate.new
  end

  def edit
    @current_overtime_option = @working_template.overtime_config.overtime_type
  end

  def create
    @working_template = WorkingTemplate.new
    dup_working_template_params = working_template_params.to_h
    if dup_working_template_params[:valid_work_sections_attributes]
      dup_working_template_params[:valid_work_sections_attributes] = dup_working_template_params[:valid_work_sections_attributes].values.map(&:to_h)
    end
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: @working_template, overtime_type: params[:overtime_type])
                        .call(dup_working_template_params)
    if validation_result.success?
      @working_template.attributes = validation_result.output
      @working_template.save
      if OvertimeConfig.overtime_types.value?(params[:overtime_type])
        @working_template.create_overtime_config(overtime_type: params[:overtime_type])
      else
        @working_template.create_overtime_config(overtime_type: OvertimeConfig.overtime_types[:disabled])
      end
      redirect_to @working_template, notice: 'Working Template was successfully created.'
    else
      @errors = validation_result.messages(full: true)
      if @errors[:valid_work_sections_attributes]&.is_a?(Hash)
        nested_error_hash = @errors[:valid_work_sections_attributes]&.values&.flatten&.reduce({}, :merge)
        @errors = @errors.except(:valid_work_sections_attributes).merge(nested_error_hash)
      end
      @current_overtime_option = params[:overtime_type]
      @working_template = WorkingTemplate.new(working_template_params)
      render :new
    end
  end

  def update
    dup_working_template_params = working_template_params.to_h
    if dup_working_template_params[:valid_work_sections_attributes]
      dup_working_template_params[:valid_work_sections_attributes] = dup_working_template_params[:valid_work_sections_attributes].values.map(&:to_h)
    end
    validation_result = UpdateWorkingTemplateValidator::Schema
                        .with(record: @working_template, overtime_type: params[:overtime_type])
                        .call(dup_working_template_params.to_h)
    if validation_result.success?
      @working_template.update(validation_result.output)
      if OvertimeConfig.overtime_types.value?(params[:overtime_type])
        @working_template.overtime_config.update(overtime_type: params[:overtime_type])
      else
        @working_template.overtime_config.update(overtime_type: OvertimeConfig.overtime_types[:disabled])
      end
      redirect_to @working_template, notice: 'Working Template was successfully updated.'
    else
      @current_overtime_option = params[:overtime_type]
      @errors = validation_result.messages(full: true)
      if @errors[:valid_work_sections_attributes]&.is_a?(Hash)
        nested_error_hash = @errors[:valid_work_sections_attributes]&.values&.flatten&.reduce({}, :merge)
        @errors = @errors.except(:valid_work_sections_attributes).merge(nested_error_hash)
      end
      render :edit
    end
  end

  def destroy
    # TODO: clear working day if default template is destroyed (should alert user about this deletion)
    if @working_template.default_templates.none? && @working_template.working_days.none?
      @working_template.destroy
      redirect_to working_templates_url, notice: 'Working Template was successfully destroyed.'
    else
      redirect_to working_templates_url, notice: 'Working Template cannot be destroyed because there have default templates or working days are linking to it.'
    end
  end

  def edit_working_template_overtime
    @current_overtime_option = @working_template.overtime_config.overtime_type
    @minutes_to_hours_minutes_string = minutes_to_hours_minutes_string(@total_sections_minutes)
  end

  def update_working_template_overtime
    validation_result = UpdateWorkingTemplateOvertimeValidator::Schema
                        .with(
                          total_sections_minutes: @total_sections_minutes,
                          overtime_type: params[:overtime_type]
                        )
                        .call(working_template_overtime_params.to_h)
    if validation_result.success?
      @working_template.update(validation_result.output)
      if OvertimeConfig.overtime_types.value?(params[:overtime_type])
        @working_template.overtime_config.update(overtime_type: params[:overtime_type])
      else
        @working_template.overtime_config.update(overtime_type: OvertimeConfig.overtime_types[:disabled])
      end
      redirect_to @working_template, notice: 'Working Template Overtime was successfully updated.'
    else
      @current_overtime_option = params[:overtime_type]
      @minutes_to_hours_minutes_string = minutes_to_hours_minutes_string(@total_sections_minutes)
      @errors = validation_result.messages(full: true)
      @working_template[:override_working_minutes] = working_template_overtime_params[:override_working_minutes]
      render :edit_working_template_overtime
    end
  end

  private

  def set_working_template
    @working_template = WorkingTemplate.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def working_template_params
    params
      .require(:working_template)
      .permit(
        :name,
        :override_working_minutes,
        valid_work_sections_attributes: %i[id from_time_in_minute to_time_in_minute _destroy]
      )
  end

  def working_template_overtime_params
    params.require(:working_template).permit(:override_working_minutes)
  end

  def set_overtime_options
    @overtime_options = OvertimeConfig.overtime_types.values
  end

  def set_total_sections_minutes
    @total_sections_minutes = @working_template.valid_work_sections.sum(&:to_time_in_minute) -
      @working_template.valid_work_sections.sum(&:from_time_in_minute)
  end
end
