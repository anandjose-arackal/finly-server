class Gatekeeper::Event
  include Supporters::ErrorTracker

  attr_accessor :event, :params

  def self.call(event, params)
    self.new(event, params).run
  end

  def initialize(event, params)
    self.event = event
    self.params = params
  end

  def run
    result = nil
    Gatekeeper::Registry.subscribers(event)&.each do |rule|
      result = rule.verdict(self.params)
      return result unless result.success?
    end
    result
  end

end