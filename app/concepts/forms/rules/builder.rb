class Forms::Rules::Builder

  def [](entity_path)
    Forms::Rules::Operator.new(entity_path)
  end

end
