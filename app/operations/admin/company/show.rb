class Admin::Company::Show < Admin::Company::Base

  attr_accessor :company

  def init
    self.company = Company.find_by(id: params[:id])
  end


end