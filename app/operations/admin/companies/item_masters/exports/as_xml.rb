class Admin::Companies::ItemMasters::Exports::AsXml < ItemMaster::Item::Exports::Generate
attr_accessor :file_url, :file, :items

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
    self.items = company.items.non_deleted.includes_for_export
  end
end