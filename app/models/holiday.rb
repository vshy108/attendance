class Holiday < ApplicationRecord
  ransacker :valid_date, type: :date do
    Arel.sql("date_part('year', valid_date)")
  end
end
