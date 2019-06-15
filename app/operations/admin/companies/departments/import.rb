class Admin::Companies::Departments::Import < Company::Departments::Import
  attr_accessor :file_url, :file, :result_hash, :params, :missing_params, :sheet, :header, :company, :department, :sub_department, :department_params

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
    self.file = params[:file]
    self.result_hash = {}
    if file.present?
      self.sheet = ImportUtil.open_spreadsheet(file)
      self.header = sheet.row(1)
    end
  end
end