class Report::Show < Report::Base

  def self.call(user, params)
    self.new(user, params).run
  end

end
