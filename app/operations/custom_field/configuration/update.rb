class CustomField::Configuration::Update < CustomField::Configuration::Base
  attr_accessor :field_configuration, :update_params, :default_value

  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Configuration not loaded correctly'
      return
    end
    if params[:field_configuration].blank? or params[:field_configuration][:id].blank?
      add_message :error, 'Field configuration not found'
    end
  end

  def init
    id = params[:id]
    self.field_configuration = CustomField::Configuration::Index.(user, params).field_configurations.with_id(id).first rescue nil
    self.default_value = params[:field_configuration][:default_value] if params[:field_configuration].present? and params[:field_configuration][:default_value].present?
    self.update_params = config_strong_params
  end

  def validate
    if self.update_params.blank? and self.default_value.blank?
      add_message :error, 'Nothing ot update'
    end
  end

  def authorize
    if field_configuration.blank?
      add_message :error, 'Field configuration not found'
      raise_unauthorized_exception
    end
  end

  def process
    self.field_configuration.assign_attributes self.update_params
    self.field_configuration.set_default_value self.default_value
    unless self.field_configuration.save
      add_message :error, self.field_configuration.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Updated'
  end

  protected
  def config_strong_params
    params.require(:field_configuration).permit(:field_name, :enabled, :mandatory,
                                                amount_attributes: [:value, :currency],
                                                drop_down_items_attributes: [:name])
  end

end