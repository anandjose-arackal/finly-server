class Policy::Show < Policy::Base
  attr_accessor :policy, :users, :mappings, :policy_users

  class Policy::Show::ShowPresenter < Policy::Base::PolicyPresenter
    attr_accessor :policy, :policy_users

    def init
      self.policy = params[:policy]
      self.policy_users = params[:policy_users]
    end

    def policy_custom_fields
      self.policy.field_configurations.filter_dropdowns
    end

    def company_managers
      policy.company.managers.signed_up
    end

    def company_finance_managers
      policy.company.finance_managers.signed_up
    end

    def categories
      policy.company.categories.active
    end

    def editable
      if user.policy_admin?(self.policy)
        return true
      end
      false
    end

    def users
      users = []
      policy.user_mapping.each do |map|
        user = map.user
        admin = map.admin
        conditional_manager = nil
        conditional_finance = nil
        conditional_approves_to = nil
        conditional_approves_finance_to = nil

        mappings = user.team_mapping.with_details.policy(policy.id)
        dm = mappings.default
        default_mapping = dm.first if dm.present?
        conditional_mapping = mappings.non_default
        cm = conditional_mapping.manager
        conditional_manager = cm.first if cm.present?
        cf = conditional_mapping.finance_manager
        conditional_finance = cf.first if cf.present?
        cat = conditional_mapping.approves_to
        conditional_approves_to = cat.first if cat.present?
        caft = conditional_mapping.approves_finance_to
        conditional_approves_finance_to = caft.first if caft.present?

        users << {user: user, admin: admin, default_mapping: default_mapping, default: default_mapping, conditional_manager: conditional_manager,
                  conditional_finance: conditional_finance, conditional_approves_to: conditional_approves_to,
                  conditional_approves_finance_to: conditional_approves_finance_to}
      end
      users
    end

  end

  def authorized_user_types
    [:company_admin, :policy_admin, :employee, :auditor]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'No user or policy params passed'
    end
  end

  def init
    id = (params[:policy_id] or params[:id])
    self.policy = Policy::Index.(user, params).policies.with_id(id)&.first
    self.mappings = []

    user_ids = self.policy.user_mapping.exclude_deleted.pluck(:user_id)
    self.policy_users = user.company.users.with_id(user_ids)
  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end

  def success
    params[:policy] = self.policy
    params[:policy_users] = self.policy_users
    Policy::Show::ShowPresenter.new(user, params, messages)
  end


end
