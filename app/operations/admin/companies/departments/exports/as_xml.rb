class Admin::Companies::Departments::Exports::AsXml < Company::Departments::Exports::AsXml
  attr_accessor :file_url, :file, :departments

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters. please try again"
    end
  end

  def user_model
    AdminUser
  end

  def init
    self.company = Company.find_by_id params[:company_id].to_i
    self.departments = company.departments.roots
  end
end