class Integrations::Base

  attr_accessor :company, :selected_user

  def initialize(company, params)
    self.company = company
    self.params = params
  end


end