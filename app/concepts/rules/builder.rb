class Rules::Builder

  def self.[](entity_path)
    Rules::Operator.new(entity_path)
  end

end
