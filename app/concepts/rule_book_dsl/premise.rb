class RuleBookDSL::Premise < RuleBookDSL::API

  def rule(description, &block)
    RuleBookDSL::Rule.new(self.act, self.chapter, self.page_tree, self.name, description, &block)
  end

end