class Company::Departments::Base < BaseOperation

  def init
    self.company = user.company if params[:company_id].blank?
    self.company = Company.find_by_id params[:company_id] if params[:company_id].present?
  end

end