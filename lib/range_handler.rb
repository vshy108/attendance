module RangeHandler
  def intersection(first_inclusive_range, second_inclusive_range)
    return nil if (first_inclusive_range.max < second_inclusive_range.begin or second_inclusive_range.max < first_inclusive_range.begin)
    [first_inclusive_range.begin, second_inclusive_range.begin].max...[first_inclusive_range.max, second_inclusive_range.max].min
  end
end
