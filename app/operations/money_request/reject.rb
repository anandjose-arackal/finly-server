class MoneyRequest::Reject < MoneyRequest::Base
  attr_accessor :reject_to_user, :status

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    id = (params[:id] or params[:request_id])
    if id.blank?
      messages[:error] << 'Request not found'
    end
  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_request = user.controlling_money_requests.with_id(id).first rescue nil
    if params[:reject_to_user_id].present?
      rejectable_users = User::Team::Review::RejectToUsersList.(self.money_request, self.user)
      self.reject_to_user = rejectable_users.with_id(params[:reject_to_user_id]).first if rejectable_users.present?
      return if self.reject_to_user.blank?
      if money_request.user.id == self.reject_to_user.id
        self.status = MoneyRequestStatus.id_for(:rejected)
      else
        self.status = MoneyRequestStatus.id_for(:processing)
      end
    else
      self.reject_to_user = self.money_request.user
      self.status = MoneyRequestStatus.id_for(:rejected)
    end
  end

  def authorize
    super
    unless money_request.controlling_user.id == user.id
      messages[:error] << 'You cannot reject the request at the moment'
      raise_unauthorized_exception
    end
  end

  def validate
    unless money_request.processing?
      messages[:error] << 'Cannot reject this request as the request is not processing'
      return
    end
    unless reject_to_user.present?
      messages[:error] << 'Reject to user not found'
    end
  end

  def process
    user_role = User::Team::Review::UserRole.(user, self.money_request)
    note= (params[:note] or params[:memo] or money_request.memo)
    if money_request.update_attributes status_id: status, controlling_user_id: reject_to_user.id, controlling_for_user_id: nil, memo: note
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:reject), status_id: status, memo: note,
                                  user_request_role_id: user_role
      money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:reject), rejected_to_id: reject_to_user.id, content: note
      return
    end
    messages[:error] = money_request.errors.full_messages
  end
end