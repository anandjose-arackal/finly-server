class Company::Departments::Base < BaseOperation

  def init
    self.company = user.company
  end

end