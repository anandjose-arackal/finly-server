class AdminOperations::Company::Show < AdminOperations::Company::Base

  def init
    self.company = Company.find_by(id: params[:id])
  end


end