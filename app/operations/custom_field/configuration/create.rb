class CustomField::Configuration::Create < CustomField::Configuration::Base
  attr_accessor :config_params, :default_value

  # todo: Policy admins are permitted to create only for their policy and users within the policy

  def authorized_user_types
    [:admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:field_configuration].blank?
      add_message :error, 'Error loading configuration. Parameters not present'
    end
  end

  def pre_authorize
    if not user.company_admin? and (params[:field_configuration][:configurable_type].blank? or params[:field_configuration][:configurable_type] != 'Policy')
      raise_unauthorized_exception
    end
  end

  def init
    params[:field_configuration][:company_id] = self.user.company_id
    self.config_params = config_strong_params
    self.default_value = params[:field_configuration][:default_value] if config_params.present? and params[:field_configuration][:default_value].present?
  end

  def authorize
    if not user.company_admin? and user.policy_admin?
      policy_id = params[:field_configuration][:configurable_id]
      policies_presenter = Policy::Index.(user, view: 'admin')
      unless policies_presenter.policies.with_id(policy_id).present?
        raise_unauthorized_exception
      end
    end
  end

  def validate
    if config_params.blank?
      add_message :error, 'Custom field configuration not found'
    end
  end

  def process
    self.field_configuration = FieldConfiguration.new config_params
    self.field_configuration.set_default_value default_value if default_value.present?
    if self.field_configuration.save
    else
      add_message :error, field_configuration.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Field Configuration Created'
  end

  protected
  def config_strong_params
    params.require(:field_configuration).permit(:field_name, :enabled, :field_type_id, :mandatory,
                                                :field_parent_type_id, :configurable, :configurable_id,
                                                :configurable_type,
                                                :company_id, amount_attributes: [:value, :currency],
                                                drop_down_items_attributes: [:name])
  end

end