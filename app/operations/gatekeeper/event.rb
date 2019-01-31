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
    Gatekeeper::Master.observers.each do |observer|
      rules = observer.send(event)
      rules.each do |rule|
        result = rule.verify(self.params)
      end
    end
  end

end