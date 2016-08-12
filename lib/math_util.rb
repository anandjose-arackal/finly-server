module MathUtil
  def precision_value(float_n)
    # float_n.to_d.round(2, :truncate).to_f
    float_n.round(2)
  end
end