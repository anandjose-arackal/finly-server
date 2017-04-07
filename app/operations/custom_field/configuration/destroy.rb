class CustomField::Configuration::Destroy < CustomField::Configuration::Base
  attr_accessor :field_configuration

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
    if params[:id].blank? and params[:field_configuration_id].blank?
      add_message :error, 'Field configuration not found'
    end
  end

  def init
    id = (params[:id] or params[:field_configuration_id])
    self.field_configuration = CustomField::Configuration::Index.(user, params).field_configurations.with_id(id).first rescue nil
  end

  def authorize
    if field_configuration.blank?
      add_message :error, 'Field configuration not found'
    end
  end

  def process
    unless self.field_configuration.destroy
      add_message :error, self.field_configuration.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Field removed'
  end

end