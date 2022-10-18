module Pagination
  def generate_link(pagy)
    limit = pagy.vars[:items]
    current_page = pagy.page
    first_page_url = url_for(limit: limit)
    {
      first: first_page_url,
      self: current_page == 1 ? first_page_url : url_for(limit: limit, page: current_page),
      next: pagy.next ? url_for(limit: limit, page: pagy.next) : nil,
      last: url_for(limit: limit, page: pagy.last)
    }
  end

  def assign_limit(limit)
    # default is 20
    limit = limit.to_i if limit.is_a? String
    Pagy::VARS[:items] = limit if limit.positive?
  end
end
