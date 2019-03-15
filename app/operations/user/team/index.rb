# action that gives the list of users in a particular user's team
# params:
# role_id: the role of the user viewing the team
# if role_id is not passed, the view of the particular user is used

class User::Team::Index < User::Team::Base
  attr_accessor :role_id, :purpose_id

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
  has_scope :filter_vendor_payments
  has_scope :yes_bank_account_transfer
  has_scope :filter_vendor_payments_reviewers
  has_scope :filter_em_reviewers
  has_scope :filter_unassigned_travel_for_policy
  has_scope :filter_unassigned_finance_for_policy
  has_scope :filter_unassigned_creditor_for_policy
  has_scope :filter_unassigned_members_for_policy

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
      if params[:view] == 'finance'
        params[:view] = 'finance_manager'
      end
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
  end

  def authorize
    case role_id
      when UserRole.admin_id, UserRole.id_for(:auditor)
        unless user.admin? || user.vendor_payments_admin? || user.auditor?
          messages[:error] << 'User is not an Admin'
          raise_unauthorized_exception
        end
      when UserRole.finance_manager_id
        unless user.finance_manager? || user.vendor_payments_creditor?
          messages[:error] << 'User is not a Finance Manager'
          raise_unauthorized_exception
        end
      when UserRole.manager_id
        unless user.manager? || user.vendor_payments_reviewer?
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
    # if the url does not include 'disburse' we know it's from expense management, and we only need users enabled for expense management
    params[:filter_expense_management] = '1'
  end

  def configure_disburse
    # adding filters so that only users subscribed to disburse will be shown in the disburse panel
    params[:filter_disburse] = '1'
  end

  def pre_process
    self.purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
  end

  def process
    user_ids = []
    manager_association = nil
    approves_to_association = nil
    case role_id
      when UserRole.admin_id, UserRole.id_for(:auditor)
        self.response = admin_team
        return
      when UserRole.finance_manager_id
        # manager_association = :has_finance_manager
        # approves_to_association = :has_approves_finance_to
        #
        # NEW CODE
        policy_ids = PolicyUserRole.with_user_id(user.id).with_role_id(role_id).pluck(:policy_id)
      when UserRole.manager_id
        # manager_association = :has_manager
        # approves_to_association = :has_approves_to
        # NEW CODE
        level_ids = LevelReviewerMapping.non_deleted.with_reviewer_id(user.id).pluck(:level_id)
        level_ids += LevelUserReviewerMapping.with_reviewer_id(user.id).pluck(:level_id)
        policy_ids = ReviewalLevel.with_id(level_ids).pluck(:policy_id)
      when UserRole.id_for(:travel_manager)
        # manager_association = :has_travel_manager
        #approves_to_association = :has_approves_travel_to
        # NEW CODE
        policy_ids = PolicyUserRole.with_user_id(user.id).with_role_id(role_id).pluck(:policy_id)
    else
      return
    end
    # return if manager_association.blank? #or approves_to_association.blank?
    # user_ids += UserManagerMapping.send(manager_association, user.id).send('with_purpose', purpose_id).pluck(:user_id)
    # if approves_to_association.present?
    #   # the below are the managers for which our current user is the 'approves_to'
    #   manager_ids = UserManagerMapping.send(approves_to_association, user.id).send('with_purpose', purpose_id).pluck(:user_id)
    #   user_ids += UserManagerMapping.send(manager_association, manager_ids).send('with_purpose', purpose_id).pluck(:user_id)
    # end
    # user_ids.uniq! if user_ids.present?
    # self.response = user.company.users.with_id(user_ids)
    #
    # NEW CODE
    user_ids = PolicyUserMapping.non_deleted.where(policy_id: policy_ids).pluck(:user_id)
    user_ids.uniq! if user_ids.present?
    self.response = user.company.users.with_id(user_ids)
  end

  def retrieve
    ScopeUtils.fix_for_scoping(params, :filter_role, :array)
    ScopeUtils.fix_for_scoping(params, :filter_state, :array)
    ScopeUtils.fix_for_scoping(params, :with_cards_having_card_program, :array)
    filter_team
    filter_group_items = (params&.dig(:filter_group) or params&.dig(:filter_group_items))
    filter_group(filter_group_items) if filter_group_items.present?
    apply_scopes(self.response, params) if self.response.present?
  end

  protected
  def filter_group(filter_group_items)
    return unless self.response.present? and filter_group_items.present?
    # filter_group_items = (params&.dig(:filter_group) or params&.dig(:filter_group_items))
    # return unless filter_group_items.present?
    group_ids = user.company.user_groups.pluck(:id)
    group_items = UserGroupItem.with_user_group(group_ids).with_id(filter_group_items)
    selected_group_ids = group_items.pluck(:user_group_id).uniq
    selected_group_ids.each do |id|
      user_ids = UserGroupItemMapping.with_group(id).with_group_item(filter_group_items).pluck(:user_id)
      self.response = self.response.with_id(user_ids)
    end
  end

  def filter_team
    return unless self.response.present?
    filter_team = (params[:filter_team] or params[:team_id] or params[:user_team_id])
    return unless filter_team.present?
    user_team = user.company.user_teams.find_by(id: filter_team)
    return unless user_team.present?
    filter_group user_team.user_group_items.pluck(:id).uniq
  end

  private
  def admin_team
    clear_messages
    if user.company_admin? || user.auditor?
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
