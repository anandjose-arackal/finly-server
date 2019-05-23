class Admin::Companies::Locations::Exports::AsXml < Company::Locations::Exports::AsXml
  attr_accessor :file_url, :file, :locations

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
    self.locations = company.locations.includes(:state)
  end
end