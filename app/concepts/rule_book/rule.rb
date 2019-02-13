class RuleBook::Rule
  attr_accessor :before_blocks, :act, :chapter, :page_tree, :description, :premise, :block, :before_blocks

  def initialize(act, chapter, page_tree, premise, description, before_blocks, &block)
    self.act = act
    self.chapter = chapter
    self.page_tree = page_tree
    self.premise = premise
    self.description = description
    self.before_blocks = before_blocks&.dup || []
    self.block = block
    self.act.subscribe premise, self
  end

  def verdict(params)
    self.chapter.verdict.new(self, params)
  end

end