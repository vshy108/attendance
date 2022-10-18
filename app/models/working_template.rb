class WorkingTemplate < ApplicationRecord
  has_many :valid_work_sections, dependent: :destroy
  has_many :working_days, dependent: :restrict_with_exception
  # NOTE: cannot delete if any default template linking to it
  has_many :default_templates, dependent: :destroy
  has_one :overtime_config, dependent: :destroy
  # NOTE: cannot delete if any repeat template parts linking to it
  has_many :repeat_template_parts, dependent: :nullify
  accepts_nested_attributes_for :valid_work_sections, allow_destroy: true
end
