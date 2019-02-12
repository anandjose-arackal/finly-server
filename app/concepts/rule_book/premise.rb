class RuleBook::Premise < RuleBook::API

  def rule(description, &block)
    RuleBook::Rule.new(self.act, self.chapter, self.page_tree, self.name, description, &block)
  end

end