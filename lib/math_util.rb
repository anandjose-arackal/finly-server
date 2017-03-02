module MathUtil
  def precision_value(float_n)
    # float_n.to_d.round(2, :truncate).to_f
    float_n.to_d.round(2) rescue 0
  end

  def generate_random_number(digits)
    (0...digits).map { (48 + rand(10)).chr }.join
  end
end