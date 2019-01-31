class RuleBook::Rule < NonPersistentModel

  attr_accessor :event, :options, :description, :block, :page

  validates :event, presence: true
  validates :description, presence: true
  validates :block, presence: true
  validates :page, presence: true

  def self.with_attrs(*attrs)
    Class.new(self) do
      attr_accessor *attrs
    end
  end

  def self.attributes
    base_attrs = [:event, :options, :description, :block, :page]
    base_attrs += self.instance_methods(false).map(&:to_s).keep_if {|a| a.include?('=')}.map {|a| a.sub('=', '')}
    base_attrs.uniq
  end

  def check(params)
    unless valid?
      raise "Rule error: #{errors.full_messages} for #{self.page&.name}"
    end

    attr = self.class.attributes
    request = {}
    attr.each do |a|
      request[a&.to_sym] = self.send a
    end
    request[:params] = params
    result = RuleBook::RuleVerifier.new(request.with_indifferent_access)
    result.verify(params)
  end

  def to_s
    {event: self.event, description: self.description, block: block, page: page}.to_s
  end

  protected

  def process(params)
    block.call(params)
  end

end