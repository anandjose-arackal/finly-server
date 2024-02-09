class CustomField::Configuration::Create < CustomField::Configuration::Base
  attr_accessor :config_params, :default_value

  # todo: Policy admins are permitted to create only for their policy and users within the policy
  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
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
    if not (user.company_admin? || user.vendor_payments_admin?) and (params[:field_configuration][:configurable_type].blank? or params[:field_configuration][:configurable_type] != 'Policy')
      raise_unauthorized_exception
    end
  end

  def init
    if params&.dig(:field_configuration, :global).present?
      params[:field_configuration][:global] = StringUtils.to_bool params&.dig(:field_configuration, :global)
    end
    if params&.dig(:field_configuration, :mandatory).present?
      params[:field_configuration][:mandatory] = StringUtils.to_bool params&.dig(:field_configuration, :mandatory)
    end
    self.config_params = config_strong_params
    config_params[:company_id] = self.user.company_id
    if config_params[:configurable_type]&.downcase == 'company'
      config_params[:configurable_type] = 'Company'
      config_params[:configurable_id] = self.user.company_id
    end
    self.default_value = params[:field_configuration][:default_value] if config_params.present? and params&.dig(:field_configuration, :default_value).present?
    self.config_params[:global] = !!config_params[:global]
    if config_params[:field_type_id]&.to_i == FieldType.id_for(:text) and config_params&.has_key?(:drop_down_items_attributes)
      config_params.delete(:drop_down_items_attributes)
    end
  end

  def authorize
    return true if user.vendor_payment_admin?
    if not user.company_admin? and user.policy_admin?
      policy_id = config_params[:configurable_id]
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

  def pre_process
    # here we will accept the params that are coming in as parent dependent field configurations
    # and create them along with the field configuration object
    if params&.dig(:field_configuration, :parent_drop_down_ids).present?
      drop_down_ids = params&.dig(:field_configuration, :parent_drop_down_ids)
      self.config_params[:parent_dependent_field_configuration_mappings] = []
      drop_down_ids.each do |ddi|
        self.config_params[:parent_dependent_field_configuration_mappings] << {
            parent_type: "FieldDropDownItem",
            parent_id: ddi
        }
      end
    end
  end

  def process
    self.field_configuration = FieldConfiguration.new config_params
    self.field_configuration.set_default_value default_value if default_value.present?
    unless self.field_configuration.save
      add_message :error, field_configuration.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Field Configuration Created'
  end

  protected

  def config_strong_params
    params.require(:field_configuration).permit(
        :field_name, :enabled, :field_type_id, :mandatory, :configurable, :configurable_id,
        :configurable_type, :global,
        field_parent_mappings_attributes: [:field_parent_type_id],
        drop_down_items_attributes: [:name],
        policy_field_mappings_attributes: [:policy_id]
    )
  end

end