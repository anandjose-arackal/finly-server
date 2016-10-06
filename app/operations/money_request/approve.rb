class MoneyRequest::Approve < MoneyRequest::Base
  attr_accessor :auto_approve

  def authorized_user_types
    [:manager, :finance_manager, :admin]
  end

  def pre_validate
    if params[:id].blank? and params[:money_request_id].blank?
      messages[:error] << 'Request not found'
    end
    if user.blank?
      messages[:error] << 'User not found'
    end

  end

  def init
    id = (params[:id] or params[:money_request_id])
    self.money_request = user.controlling_money_requests.with_id(id).first rescue nil
    self.auto_approve = params[:auto_approve]
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
    end
    unless money_request.controlling_user_id == user.id
      raise_unauthorized_exception
    end
  end

  def validate
    unless money_request.processing? or params[:auto_approve]
      messages[:error] << 'Cannot approve this request as it is not in processing state'
    end
    validate_payment_mode
  end

  def validate_payment_mode
    unless money_request.payment_mode_id == PaymentMode.id_for(:cash)
      messages[:error] << 'Error approving advance request. Use approve and forward action'
    end
  end

  def process
    presenter = User::Team::Review::NextReviewer.(money_request)
    manager = presenter.user
    to_user_role_id = presenter.role_id
    status = MoneyRequestStatus.id_for(:processing)
    if auto_approve or manager.blank?
      status = MoneyRequestStatus.id_for(:approved)
    end
    manager_id = manager.id rescue nil
    curr_user_role = User::Team::Review::UserRole.(user, self.money_request)
    update_attributes = {status_id: status, controlling_user_id: manager_id, controlling_for_user_id: nil,
                         controlling_user_role_id: to_user_role_id,controlling_for_user_role_id: nil,
                         memo: self.params[:memo]}
    update_attributes[:submitted_at] = DateTime.now if auto_approve
    if money_request.update_attributes update_attributes
      if auto_approve
        money_request.tracks.create action_user: nil,
          money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:auto_approve),
          status_id: status, modified_user: nil, modified_user_role_id: nil
        self.money_request.comments.create comment_action_id: MoneyRequestCommentAction.id_for(:auto_approve)
      else
        money_request.tracks.create action_user: user, modified_user_id: money_request.controlling_user_id,
          modified_user_role_id: to_user_role_id,
          money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:approve),
          status_id: status, user_request_role_id: curr_user_role
        self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:approve)
      end
      return true
    end
    messages[:error] = money_request.errors.full_messages
  end

  def post_process
    # # Handle for money requests which have payment mode as card
    # result = nil
    # if money_request.approved? and money_request.payment_mode_id == PaymentMode.id_for(:card)
    #   result = MoneyRequest::Card::AutoCredit.(user, money_request: money_request)
    #   if result.success?
    #     messages[:success] = result.messages[:success]
    #     return
    #   else
    #     messages[:error] = result.messages[:error]
    #   end
    # end

    # todo computing settlements
    unless money_request.processing?
      Settlement::MoneyRequest::Approved.(user, money_request: money_request)
      money_request.reload
    end

    # todo sending notifications
    Event::MoneyRequest::Approve.(self.user, money_request: self.money_request)

    if not has_errors? and money_request.payment_mode_id == PaymentMode.id_for(:cash)
      messages[:success] << 'Successfully approved the advance request'
    end
  end
end
