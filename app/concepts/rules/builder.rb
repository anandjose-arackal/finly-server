class Rules::Builder

  def self.[](entity_path)
    Rules::Operator.new(entity_path)
  end

  def self.call(rule)
    grammar = Rules::Grammar::Parser.new
    Rules::Adapters::Grammar.load(grammar.parse(rule))
  end

end
