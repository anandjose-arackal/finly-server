class Policy::Show < Policy::Base

  attr_accessor :policy, :users

  class Policy::Show::ShowPresenter < Policy::Base::PolicyPresenter

    attr_accessor :policy, :users

    def initialize(user, params)
      self.policy = params[:policy]
      self.users = params[:users]
    end

    def company_managers
      policy.company.managers
    end

    def company_finance_managers
      policy.company.finance_managers
    end

    def categories
      policy.company.categories.active
    end

  end

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or policy params passed."
    end
  end

  def init
    self.policy = user.policies.find_by(params[:policy_id] || params[:id])
  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end

  def process
    self.users = []
    policy.user_mapping.each do |map|
      user = map.user
      admin = map.admin
      conditional_manager = nil
      conditional_finance = nil
      conditional_approves_to = nil
      conditional_approves_finance_to = nil

      mappings = user.team_mapping.with_details.policy(@policy.id)
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

      users << {user: user, admin: admin, default_mapping: default_mapping, conditional_manager: conditional_manager,
                 conditional_finance: conditional_finance, conditional_approves_to: conditional_approves_to,
                 conditional_approves_finance_to: conditional_approves_finance_to}
    end
  end

  def retrieve
    if is_success?
      Policy::Show::ShowPresenter.new(user, {policy: policy, users: users})
    else
      false
    end
  end

end
