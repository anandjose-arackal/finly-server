class CustomField::Configuration::Users::Add < CustomField::Base

  attr_accessor :field_configuration, :selected_users, :drop_downs

  def init
    self.selected_users = user.company.users.with_email_or_mobile_number(params[:user_id], params[:user_id])
    self.field_configuration = user.company.field_configurations.find_by(id: params[:custom_field_id])
    self.drop_downs = self.field_configuration&.drop_down_items&.with_id(params[:drop_down_ids])
  end

  def validate
    if selected_users.blank?
      add_message :error, "Users not found"
      return
    end

    if self.field_configuration.blank?
      add_message :error, "Field configuration not found"
      return
    end

    if self.drop_downs.blank?
      add_message :error, "No dropdowns to add"
      return
    end
  end

  def process
    self.drop_downs.each do |drop_down|
      self.selected_users.each do |user|
        UserDropDownItemMapping.find_or_create_by(user_id: user.id, drop_down_item_id: drop_down.id)
      end
    end
  end

  def post_process
    add_message :success, "Associated drop downs with users"
  end

end