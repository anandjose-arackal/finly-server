class Gatekeeper::Trigger

  def self.call(event, options)
    self.new(event, options).run
  end



end