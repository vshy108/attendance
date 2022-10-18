class DefaultTemplate < ApplicationRecord
  belongs_to :working_template
  belongs_to :worker
end
