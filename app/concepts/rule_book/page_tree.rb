# Provides bread crumbs
class RuleBook::PageTree
  attr_accessor :tree, :premise

  def initialize(item, page_tree = nil)
    self.tree = page_tree&.tree&.dup || []
    self.tree = [item]
    self.premise = page_tree&.premise
  end

  def add(item)
    pt = self.class.new(item, self)
    pt.premise = item if item.is_a?(RuleBook::Premise)
    pt
  end

  def to_s(options = {})
    name = ''
    self.tree.each do |item|
      name += " > " unless name.blank?
      name += "#{item.name}"
    end
    name
  end

end