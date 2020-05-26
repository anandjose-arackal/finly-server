class Rules::Builder

  def [](entity_path)
    Rules::Operator.new(entity_path)
  end

end
