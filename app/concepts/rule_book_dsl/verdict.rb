class RuleBookDSL::Verdict < RuleBookDSL::Rule
  include DynamicProperty

  attr_accessor :executed, :failed

  def init
    run
  end

  def run
    instance_eval(&block)
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

end