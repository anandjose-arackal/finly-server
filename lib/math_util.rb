module MathUtil
  def precision_value(float_n)
    # todo - add condition to check the number of digits before the decimal and round accordingly
    float_n.to_d.round(2) rescue 0
  end

  def set_precision(precision, scale)

  end

  def self.generate_random_number(digits)
    (0...digits).map { (48 + rand(10)).chr }.join
  end
end