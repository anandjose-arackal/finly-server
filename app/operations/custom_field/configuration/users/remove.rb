class CustomField::Configuration::Users::Remove < CustomField::Configuration::Users::Add

  def process
    mappings = UserDropDownItemMapping.with_user_id(self.selected_users.pluck(:id)).with_drop_down_item_id(self.drop_downs.pluck(:id))
    unless mappings.destroy_all
      add_message :error, "Error while associating users"
    end
  end

  def post_process
    add_message :error, "Disassociated users successfully"
  end

end