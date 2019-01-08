class MoneyRequests::Approve < MoneyRequests::Base
  attr_accessor :auto_approve

  def authorized_user_types
    return nil if params.present? and (params[:auto_approve])
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
    # old
    # self.money_request = user.controlling_money_requests.with_id(id).first rescue nil

    # new
    self.money_request = MoneyRequest.reviewer_associated_items(user).with_id(id).first rescue nil
    self.auto_approve = params[:auto_approve]
  end

  def authorize
    unless money_request
      raise_unauthorized_exception
    end
    # OLD CODE
    # unless money_request.controlling_user_id == user.id
    #   raise_unauthorized_exception
    # end
  end

  def validate
    unless money_request.processing? or params[:auto_approve]
      messages[:error] << 'Cannot approve this request as it is not in processing state'
    end
    validate_payment_mode
  end

  def validate_payment_mode
    unless money_request.payment_mode_id == PaymentMode.id_for(:cash)
      messages[:error] << 'Error approving money request. Use approve and forward action'
    end
  end

  def process
    # presenter = User::Team::Review::NextReviewer.(money_request)
    # manager = presenter.user
    # to_user_role_id = presenter.role_id
    # status = MoneyRequestStatus.id_for(:processing)
    # approved_at = nil
    # if auto_approve or manager.blank?
    #   status = MoneyRequestStatus.id_for(:approved)
    #   approved_at = DateTime.now
    # end
    # manager_id = manager.id rescue nil
    # curr_user_role = User::Team::Review::UserRole.(user, self.money_request)
    # update_attributes = {}
    # update_attributes[:status_id] = status
    # update_attributes[:controlling_user_id] = manager_id
    # update_attributes[:controlling_for_user_id] = nil
    # update_attributes[:controlling_user_role_id] = to_user_role_id
    # update_attributes[:controlling_for_user_role_id] = nil
    # update_attributes[:submitted_at] = DateTime.now if auto_approve
    # update_attributes[:approved_at] = approved_at
    # update_attributes[:auto_approve] = self.auto_approve
    # if money_request.update_attributes update_attributes
    #   if auto_approve
    #     track_attributes = {}
    #     track_attributes[:action_user] = nil
    #     track_attributes[:money_request_tracking_action_id] = MoneyRequestTrackingAction.id_for(:auto_approve)
    #     track_attributes[:status_id] = status
    #     track_attributes[:modified_user] = nil
    #     track_attributes[:modified_user_role_id] = nil
    #     money_request.tracks.create track_attributes
    #     self.money_request.comments.create comment_action_id: MoneyRequestCommentAction.id_for(:auto_approve)
    #   else
    #     track_attributes = {}
    #     track_attributes[:action_user] = user
    #     track_attributes[:action_user_role_id] = curr_user_role
    #     track_attributes[:modified_user_id] = money_request.controlling_user_id
    #     track_attributes[:modified_user_role_id] = to_user_role_id
    #     track_attributes[:money_request_tracking_action_id] = MoneyRequestTrackingAction.id_for(:approve)
    #     track_attributes[:status_id] = status
    #     money_request.tracks.create track_attributes
    #     self.money_request.comments.create user: user, comment_action_id: MoneyRequestCommentAction.id_for(:approve)
    #   end
    #   return true
    # end
    # messages[:error] = money_request.errors.full_messages

    ###################
    # NEW CODE
    #  Workflow Manager
    params[:document] = self.money_request
    params[:aasm_event] = 'approve'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
    # NEW CODE ENDS
    ####################
  end

  def post_process
    # todo computing settlements
    unless money_request.processing?
      Settlement::MoneyRequests::Approved.(user, money_request: money_request, auto_approve: auto_approve)
      money_request.reload
    end

    Event::EMoneyRequests::Approve.(self.user, money_request: self.money_request, auto_approve: auto_approve)

    if not has_errors? and money_request.payment_mode_id == PaymentMode.id_for(:cash)
      messages[:success] << 'Successfully approved the money request'
    end
  end
end
