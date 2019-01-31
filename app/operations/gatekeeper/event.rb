class Gatekeeper::Event
  include Supporters::ErrorTracker

  attr_accessor :event, :options

  def self.call(event, options)
    self.new(event, options).run
  end

  def initialize(event, options)
    self.event = event
    self.options = options
  end

  def run
    Gatekeeper::Master.observers.each do |observer|
      rules = observer.send(event)
      rules.each do |rule|
        result = rule.run
        if result.success?

        end
      end
    end
  end

end