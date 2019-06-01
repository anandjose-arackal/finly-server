class Admin::Companies::Vendors::Exports::AsXml < Vendors::Exports::AsXml
  attr_accessor :file_url, :file, :vendors

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
    self.vendors = company.yes_bank_vendors.authorized.includes(:gstin_locations, :bank_accounts)
  end
end