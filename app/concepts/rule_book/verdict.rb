class RuleBook::Verdict < RuleBook::Rule
  include DynamicProperty

  attr_accessor :executed, :failed, :skipped, :rule, :params

  define_property :instance, :message

  def self.success_verdict
    verdict = self.new(nil, nil)
    verdict.skipped = true
    verdict
  end

  def initialize(rule, params)
    self.rule = rule
    self.params = params
    run if self.rule.present?
  end

  def run
    self.rule.before_blocks.each do |before_block|
      instance_eval(&before_block)
      executed! and return if self.skipped?
    end
    instance_eval(&self.rule.block)
    executed!
  end

  def executed!
    self.executed = true
  end

  def executed?
    !!self.executed
  end

  def success?
    self.skipped? or (self.executed? and not failed?)
  end

  def failed?
    self.executed? and !!self.failed
  end

  def skipped?
    !!self.skipped
  end

  # Used for skipping rules
  def skip
    self.skipped = true
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

  def full_description
    self.rule.full_description
  end

end