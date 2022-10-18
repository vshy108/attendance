Ransack.configure do |config|
  config.add_predicate 'year_equals',
                       arel_predicate: 'eq',
                       formatter: proc { |v| v.to_i },
                       validator: proc { |v| v.present? },
                       type: :integer
end
