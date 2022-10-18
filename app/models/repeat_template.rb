class RepeatTemplate < ApplicationRecord
  belongs_to :worker
  has_many :repeat_template_parts, dependent: :destroy
  accepts_nested_attributes_for :repeat_template_parts, allow_destroy: true
end
