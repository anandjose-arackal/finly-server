class AdminOperations::Company::Show < AdminOperations::Company::Base

  attr_accessor :company

  def init
    self.company = Company.find_by(id: params[:id])
  end


end