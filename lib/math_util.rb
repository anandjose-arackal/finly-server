module MathUtil
  def precision_value(float_n, digits = 2)
    # todo - add condition to check the number of digits before the decimal and round accordingly
    float_n.to_d.round(digits) rescue 0
  end

  def set_precision(precision, scale)

  end

  def self.generate_random_number(digits)
    (0...digits).map { (48 + rand(10)).chr }.join
  end

  def self.number_with_rupee_delimiter(number)
    ("%.2f" % number).reverse.gsub(/(?<=.{6})(\d\d?)/, ',\1').reverse
  end
end