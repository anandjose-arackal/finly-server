class RuleBook::Chapter < RuleBook::API
  include DynamicProperty

  attr_accessor :page_tree, :block

  define_property :singleton, :act, :verdict

  def initialize(chapter_name, &block)
    self.page_tree = RuleBook::PageTree.new(self)
    self.name = chapter_name
    self.block = block
    run
  end

  def verdict
    self.class.verdict || RuleBook::Verdict
  end

  def chapter
    self
  end

  def act
    self.class.act
  end

end