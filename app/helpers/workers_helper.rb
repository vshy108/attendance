module WorkersHelper
  include Pagy::Frontend

  def render_overtime_value(overtime_value)
    if overtime_value.presence
      "RM #{number_with_precision(overtime_value, precision: 2)}"
    else
      '-'
    end
  end
end
