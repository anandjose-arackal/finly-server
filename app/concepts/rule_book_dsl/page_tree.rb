# Provides bread crumbs
class RuleBookDSL::PageTree
  attr_accessor :tree

  def initialize(klass, page_tree=nil)
    self.tree = page_tree&.tree&.dup || []
    self.tree = [klass]
  end

  def add(klass)
    self.class.new(klass, self)
  end

end