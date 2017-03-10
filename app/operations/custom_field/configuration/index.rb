class CustomField::Configuration::Index < CustomField::Configuration::Base
  attr_accessor :field_configurations, :policy_id, :for_company, :for_policy, :policy

  def authorized_user_types
    # Policy Admin authorization
    if user.present? and not user.company_admin? and user.policy_admin?
      unless params.present? and (params[:policy].present? or params[:for_policy].present?) and (params[:id].present? or params[:policy_id].present?)
        # Unauthorized policy admin
        return [:company_admin]
      end
      # Authorized policy admin
      return nil
    end
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Configuration not loaded correctly'
    end
  end

  def init
    self.for_company = (params[:company] or params[:for_company])
    self.for_policy = (params[:policy] or params[:for_policy])
    self.policy_id = (params[:policy_id] or params[:id])
    if for_policy and self.policy_id
      self.policy = Policy::Index.(user, params).policies.with_id(self.policy_id).first rescue nil
    end
  end

  def validate
    unless for_company or for_policy
      add_message :error, 'Configuration not loaded correctly. PLease try again'
      return
    end
    if for_policy and self.policy.blank?
      add_message :error, 'Policy not found'
    end
  end

  def process
    if for_company
      self.field_configurations = self.user.company.field_configurations
    elsif for_policy
      self.field_configurations = self.policy.field_configurations
    end
  end

  def success
    params[:field_configurations] = self.field_configurations
    CustomField::Configuration::Index::SuccessPresenter.new(self.user, params)
  end

  class CustomField::Configuration::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :field_configurations

    def init
      self.field_configurations = params[:field_configurations]
    end

  end

end