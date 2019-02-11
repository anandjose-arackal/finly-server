class RuleBook::Rule < NonPersistentModel
  attr_accessor :event, :options, :description, :block, :page

  validates :event, presence: true
  validates :description, presence: true
  validates :block, presence: true
  validates :page, presence: true

  def verify(params)
    page.index.rule_verifier.new(self, params).verify
  end

  def to_h
    {event: self.event, description: self.description, block: block, page: page, options: options}
  end

  def to_s
    to_h.to_s
  end

end