class Policy::Mappings::Show < Policy::Base
  attr_accessor :policy, :updating_user, :map

  def pre_validate
    if user.blank? or (params[:user_id].blank? and params[:id].blank? and params[:user].blank?)
      add_message :error, 'User not found'
    end
  end

  def pre_authorize
    return if params[:user].present? and params[:user].is_a?(::User)
    user_id = (params[:id] or params[:user_id])
    if user.company_admin?
      self.updating_user = user.company.users.with_id(user_id).first rescue nil
    elsif user.policy_admin?
      if params[:user_manager_mapping].present?
        admin_policy_id = user.admin_policies.pluck(:id)
        params[:user_manager_mapping].each do |key, mapping|
          unless admin_policy_id.include?(mapping[:mapping_id])
            add_message :error, 'You do not have the permission to make the following update'
            raise_unauthorized_exception
          end
        end
      end
      team = User::Team::Index.(user, view: 'admin')
      self.updating_user = team.with_id(user_id).first rescue nil
    end
  end

  def authorize
  end

  def init
    if params[:policy].present?
      self.policy = params[:policy]
    elsif params[:policy_id].present?
      self.policy = updating_user.policies.with_id(params[:policy_id]).first
    end
    if self.updating_user.blank? and params[:user].present?
      self.updating_user = params[:user]
    end
  end

  def validate
    if self.updating_user.blank?
      add_message :error, 'User not found'
    end
  end

  def process
    policy_id = self.policy.present? ? self.policy.id : nil
    company_default_mapping = updating_user.team_mapping.policy(policy_id)
    default_mapping = company_default_mapping.default
    conditional_manager = company_default_mapping.non_default.manager
    conditional_finance_manager = company_default_mapping.non_default.finance_manager
    conditional_approves_to = company_default_mapping.non_default.approves_to
    conditional_approves_finance_to = company_default_mapping.non_default.approves_finance_to
    self.map = {company_default: self.policy.nil?, policy: self.policy, default: default_mapping,
                conditional_manager: conditional_manager,
                conditional_finance_manager: conditional_finance_manager,
                conditional_approves_to: conditional_approves_to,
                conditional_approves_finance_to: conditional_approves_finance_to}
  end

  def success
    params[:map] = self.map
    return Policy::Mappings::Show::Presenter.new(user, params, messages)
  end

  class Policy::Mappings::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :map

    def init
      self.map = params[:map]
    end

    def company_default?
      self.map[:company_default]
    end

    def policy
      self.map[:policy]
    end

    def default
      self.map[:default]
    end

    def conditional_manager
      self.map[:conditional_manager]
    end

    def conditional_finance_manager
      self.map[:conditional_finance_manager]
    end

    def conditional_approves_to
      self.map[:conditional_approves_to]
    end

    def conditional_approves_finance_to
      self.map[:conditional_approves_finance_to]
    end

  end

end
