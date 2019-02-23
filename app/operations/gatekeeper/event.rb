class Gatekeeper::Event
  include Supporters::ErrorTracker

  attr_accessor :event, :params

  def self.call(event, params = {})
    self.new(event, params).run
  end

  def initialize(event, params = {})
    self.event = event
    self.params = params
  end

  def run
    Gatekeeper::Registry.subscribers(event)&.each do |rule|
      result = rule.verdict(self.params)
      unless result.success?
        gr = Gatekeeper::Log.(result, params)
        unless gr.success?
          puts gr.messages[:error]
        end
        return result
      end
    end
    Gatekeeper::Checker::Verdict.success_verdict
  end

end