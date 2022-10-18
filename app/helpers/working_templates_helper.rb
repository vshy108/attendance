module WorkingTemplatesHelper
  def time_conversion(minutes)
    if minutes.nil? || minutes == '-'
      '-'
    else
      hours = minutes / 60
      rest = minutes % 60
      return "#{hours}hrs" unless rest.positive?

      "#{hours}hrs #{rest}mins"
    end
  end
end
