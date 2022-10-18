module HomesHelper
  def render_absence_table(date_string, workers, context)
    if workers&.exists?
      @date_string = date_string
      @other_workers = workers
      context.render(partial: "/homes/has_absence_table")
    else
      context.render(partial: "/application/nil")
    end
  end
end
