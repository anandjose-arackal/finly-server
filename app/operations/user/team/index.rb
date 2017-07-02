# action that gives the list of users in a particular user's team
# params:
# role_id: the role of the user viewing the team
# if role_id is not passed, the view of the particular user is used

class User::Team::Index < User::Team::Base
  attr_accessor :role_id

  # has_scope :filter_search
  # has_scope :filter_role
  # has_scope :filter_state

  has_scope :filter_search
  has_scope :filter_state, type: :array
  has_scope :filter_role, type: :array
  has_scope :filter_reports_awaiting_settlement
  has_scope :filter_pending_money_requests
  has_scope :having_cash_on_hand_balance
  has_scope :having_wallet_balance
  has_scope :with_cards_having_card_program, type: :array
  has_scope :filter_disburse
  has_scope :filter_expense_management

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end

    if params[:filter_search].present?
      params[:filter_search].strip! if params[:filter_search].is_a?(String)
    end
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    case role_id
      when UserRole.admin_id
        unless user.admin?
          messages[:error] << 'User is not an Admin'
          raise_unauthorized_exception
        end
      when UserRole.finance_manager_id
        unless user.finance_manager?
          messages[:error] << 'User is not a Finance Manager'
          raise_unauthorized_exception
        end
      when UserRole.manager_id
        unless user.manager?
          messages[:error] << 'User is not a Manager'
          raise_unauthorized_exception
        end
      else
        #Nothing
    end
  end

  def validate
    unless role_id.present?
      messages[:error] << 'User role not defined'
    end
  end

  def configure_expense_management
    request = params[:request]
    # if the url does not include 'disburse' we know it's from expense management, and we only need users enabled for expense management
    unless request.referrer.include?('disburse')
      params[:filter_expense_management] = '1'
    end
  end

  def configure_disburse
    # adding filters so that only users subscribed to disburse will be shown in the disburse panel
    request = params[:request]
    if request.referrer.include?('disburse')
      params[:filter_disburse] = '1'
    end
  end

  def process
    user_ids = []
    manager_association = nil
    approves_to_association = nil
    case role_id
      when UserRole.admin_id
        self.response = admin_team
        return
      when UserRole.finance_manager_id
        manager_association = :has_finance_manager
        approves_to_association = :has_approves_finance_to
      when UserRole.manager_id
        manager_association = :has_manager
        approves_to_association = :has_approves_to
    end
    return if manager_association.blank? or approves_to_association.blank?
    user_ids += UserManagerMapping.send(manager_association, user.id).pluck(:user_id)
    user_ids.uniq! if user_ids.present?
    self.response = user.company.users.with_id(user_ids)
  end

  def retrieve
    ScopeUtils.fix_for_scoping(params, :filter_role, :array)
    ScopeUtils.fix_for_scoping(params, :filter_state, :array)
    ScopeUtils.fix_for_scoping(params, :with_cards_having_card_program, :array)
    apply_scopes(self.response, params) if self.response.present?
  end


  private
  def admin_team
    clear_messages
    if user.company_admin?
      return user.company.users
    elsif user.policy_admin?
      users = user.company.users
      policies = user.admin_policies.pluck(:id)
      if policies.present?
        return users.with_id(PolicyUserMapping.with_policy(policies).pluck(:user_id))
      end
    end
    messages[:error] << 'User is not an admin'
    false
  end

end