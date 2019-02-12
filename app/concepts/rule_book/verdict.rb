class RuleBook::Verdict < RuleBook::Rule
  include DynamicProperty

  attr_accessor :executed, :failed, :rule, :params

  define_property :instance, :message

  def initialize(rule, params)
    self.rule = rule
    self.params = params
    run
  end

  def run
    instance_eval(&rule.block)
    self.executed = true
  end

  def executed?
    !!self.executed
  end

  def success?
    self.executed? and not failed?
  end

  def failed?
    self.executed? and !!self.failed
  end

  def fail
    self.failed = true
  end

  def act
    self.rule.act
  end

  def chapter
    self.rule.chapter
  end

  def page_tree
    self.rule.page_tree
  end

  def premise
    self.rule.premise
  end

  def description
    self.rule.description
  end

end