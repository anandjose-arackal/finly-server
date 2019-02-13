class RuleBook::API
  attr_accessor :block, :chapter, :sections, :rules, :page_tree, :act, :premises, :name, :before_blocks

  def initialize(act, chapter, page_tree, section_name, before_blocks, &block)
    self.block = block
    self.act = act
    self.chapter = chapter
    self.name = section_name
    self.before_blocks = before_blocks&.dup || []
    self.page_tree = page_tree.add(self)
    run
  end

  def run
    instance_eval &block
  end

  def before(&block)
    self.before_blocks << block
  end

  def section(context_name, &block)
    RuleBook::Section.new(self.act, self.chapter, self.page_tree, context_name, self.before_blocks, &block)
  end

  def premise(*premise_names, &block)
    premise_names.each do |premise_name|
      RuleBook::Premise.new(self.act, self.chapter, self.page_tree, premise_name, self.before_blocks, &block)
    end
  end

end