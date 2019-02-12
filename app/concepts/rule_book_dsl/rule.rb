class RuleBookDSL::Rule
  attr_accessor :before_blocks, :act, :chapter, :page_tree, :description, :premise, :block

  def initialize(act, chapter, page_tree, premise, description, &block)
    self.act = act
    self.chapter = chapter
    self.page_tree = page_tree
    self.premise = premise
    self.description = description
    self.block = block
    self.act.subscribe premise, self
    init
  end

  def init

  end

  def verdict
    self.chapter.verdict.new(act, chapter, page_tree, premise, description, &block)
  end

end