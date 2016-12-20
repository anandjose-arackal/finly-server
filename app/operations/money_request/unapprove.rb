class MoneyRequest::Unapprove < MoneyRequest::Base
  attr_accessor :prev_status

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'User or params not passed'
    end
  end

  def authorize
    super
    if money_request.user_id == user.id
      add_message :error, 'You cannot unapprove your own money_request'
      raise_unauthorized_exception
    end
  end

  def validate
    # checking if this user can unapprove this money_request at this stage
    associated_users = money_request.associated_users money_request.controlling_user
    unless associated_users.present? and associated_users.with_id(user.id).present?
      add_message :error, 'User has not yet reviewed the money_request to unapprove it'
      return false
    end

    unless money_request.can_unapprove?
      add_message :error, 'The money_request cannot be unapproved at this stage'
    end
  end

  def process
    self.prev_status = money_request.status
    prev_controlling_user = (money_request.controlling_for_user or money_request.controlling_user)
    prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.money_request)
    role_id = nil
    # Todo verify if the user has approved the money_request as manager / finance manager
    if manager_view?
      role_id = UserRole.id_for(:manager)
    elsif finance_view?
      role_id = UserRole.id_for(:finance_manager)
    end
    memo = (params[:note] or params[:memo] or money_request.memo)
    if money_request.update_attributes controlling_user_id: user.id,
                                       controlling_for_user_id: nil,
                                       controlling_user_role_id: role_id,
                                       controlling_for_user_role_id: nil,
                                       memo: memo,
                                       status_id: MoneyRequestStatus.id_for(:processing)
      money_request.tracks.create action_user: user,
                                  action_user_role_id: role_id,
                                  modified_user: prev_controlling_user,
                                  modified_user_role_id: prev_controlling_user_role,
                                  money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:unapprove),
                                  status_id: MoneyRequestStatus.id_for(:processing)
      return
    end
    add_message :error, money_request.errors.full_messages
  end

  def post_process
    money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:unapprove)

    if prev_status.approved?
      Event::EMoneyRequest::Unapprove.(self.user, money_request: self.money_request)

      # Recalculate settlement when money_request is unapproved from an approved/closed state
      Settlement::MoneyRequest::Unapproved.(user, money_request: money_request)
    end
  end

end