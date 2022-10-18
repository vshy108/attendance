module HashHandler
  def add_default_value(hash, key, default_value)
    hash = {} if hash.nil?
    hash[key.to_sym] = default_value if hash[key.to_sym].blank?
    hash
  end

  def add_ransack_value(hash, key, value)
    hash = {} if hash.nil?
    hash[key.to_sym] = value
    hash
  end
end
