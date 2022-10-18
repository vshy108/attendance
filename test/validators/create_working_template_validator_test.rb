require 'test_helper'

class CreateWorkingTemplateValidatorTest < ActiveSupport::TestCase
  setup do
    @working_template_0 = working_templates(:working_template_0)
    @correct_basic_hash =
      {
        name: Faker::Name.unique.name,
        override_working_minutes: '100',
        valid_work_sections_attributes: [
          { _destroy: 'false', from_time_in_minute: '10', to_time_in_minute: '200' }
        ]
      }
  end

  test "should be success if use basic hash" do
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
  end

  test "should be fail if name is not unique" do
    @correct_basic_hash[:name] = @working_template_0.name
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/must be unique/, validation_result.messages[:name].first)
  end

  test "should strip and chomp on name" do
    name = Faker::Name.unique.name
    @correct_basic_hash[:name] = "#{name}  "
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
    assert_equal name, validation_result[:name]
  end

  test "should be success if override_working_minutes is empty string" do
    @correct_basic_hash[:override_working_minutes] = ''
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
    assert_equal '', validation_result.output[:override_working_minutes]
  end

  test "should be fail if override_working_minutes not less than 24 hours" do
    @correct_basic_hash[:override_working_minutes] = '1440'
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/must be less than 1440/, validation_result.messages[:override_working_minutes].first)
  end

  test "should be success if override_working_minutes has decimal places" do
    @correct_basic_hash[:override_working_minutes] = '123.6'
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
  end

  test "should be fail if override_working_minutes is negative" do
    @correct_basic_hash[:override_working_minutes] = '-1'
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/must be greater than or equal to 0/, validation_result.messages[:override_working_minutes].first)
  end

  test "should be fail if from_time_in_minute not greater than -720" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '-720', to_time_in_minute: '20' }
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(
      /must be greater than -720/,
      validation_result.messages[:valid_work_sections_attributes].values.first[:from_time_in_minute].first
    )
  end

  test "should be fail if to_time_in_minute not less than 2160" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '0', to_time_in_minute: '2160' }
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/must be less than 2160/, validation_result.messages[:valid_work_sections_attributes].values.first[:to_time_in_minute].first)
  end

  test "should be failed if from_time_in_minute and to_time_in_minute has decimal places" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '0.3', to_time_in_minute: '123.3' }
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert validation_result.messages[:valid_work_sections_attributes].values.first[:from_time_in_minute].include?("must be an integer")
    assert validation_result.messages[:valid_work_sections_attributes].values.first[:to_time_in_minute].include?("must be an integer")
  end

  test "should be fail if earliest from_time_in_minute and latest to_time_in_minute are not less than 1 day" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '0', to_time_in_minute: '120' },
      { _destroy: 'false', from_time_in_minute: '240', to_time_in_minute: '1440' }
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert validation_result.messages[:longer_one_day].any?
  end

  test "should be fail if any valid_work_sections are overlapped" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '0', to_time_in_minute: '600' },
      { _destroy: 'false', from_time_in_minute: '540', to_time_in_minute: '1000' }
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/cannot have any overlappings/, validation_result.messages[:overlapping_valid_work_sections].first)
  end

  test "should be fail if override_working_minutes is larger than total minutes of valid_work_sections" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '0', to_time_in_minute: '600' }
    ]
    @correct_basic_hash[:override_working_minutes] = '700'
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/must less than total of all valid work sections differences/, validation_result.messages[:valid_minimum_working_hours].first)
  end

  test "should be failed if from_time_in_minute is not less than to_time_in_minute" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '600', to_time_in_minute: '6' }
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/is always have from time in minute less than to time in minute/, validation_result.messages[:valid_relationship_from_to].first)
  end

  test "should be failed if no override_working_minutes for overtime type of more_than_minimum" do
    @correct_basic_hash[:override_working_minutes] = ''
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'more_than_minimum')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/is missing/, validation_result.messages[:override_working_minutes].first)
  end

  test "should be failed if no override_working_minutes for overtime type of both" do
    @correct_basic_hash[:override_working_minutes] = ''
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'both')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/is missing/, validation_result.messages[:override_working_minutes].first)
  end

  test "should be success if no override_working_minutes for overtime type of disabled" do
    @correct_basic_hash[:override_working_minutes] = ''
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
  end

  test "should be success if has override_working_minutes for overtime type of disabled" do
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'disabled')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
  end

  test "should be success if no override_working_minutes for overtime type of direct_after_off_work" do
    @correct_basic_hash[:override_working_minutes] = ''
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'direct_after_off_work')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
  end

  test "should be success if has override_working_minutes for overtime type of direct_after_off_work" do
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'direct_after_off_work')
                        .call(@correct_basic_hash)
    assert_equal true, validation_result.success?
  end

  test "should be failed if has from_time_in_minute larger than to_time_in_minute in items other than the first one" do
    @correct_basic_hash[:valid_work_sections_attributes] = [
      { _destroy: 'false', from_time_in_minute: '10', to_time_in_minute: '200' },
      { _destroy: 'false', from_time_in_minute: '300', to_time_in_minute: '250' },
    ]
    validation_result = CreateWorkingTemplateValidator::Schema
                        .with(record: WorkingTemplate.new, overtime_type: 'direct_after_off_work')
                        .call(@correct_basic_hash)
    assert_equal false, validation_result.success?
    assert_match(/less than to/, validation_result.messages[:valid_relationship_from_to].first)
  end
end
