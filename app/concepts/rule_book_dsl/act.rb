class RuleBookDSL::Act < RuleBookDSL::API
  include EventBus::Bus

  attr_accessor :rules, :page_tree, :context

  def self.chapters_path(path)
    subscribers_path path
  end

end