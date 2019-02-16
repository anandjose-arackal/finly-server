class MoneyRequests::MarkAsCredited < MoneyRequests::Base
  attr_accessor :payment, :money_requests, :amount_credited

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def init
    self.money_request = (params[:money_request] or params[:money_requests])
    self.payment = params[:payment]
    self.amount_credited = params[:amount_processed].to_f
  end

  def validate
    unless money_request.payment_pending?
      messages[:error] << 'Money Request cannot be credited at this stage'
    end
  end

  def process
    # if money_request.update_attributes controlling_user: nil,
    #                                    controlling_for_user: nil,
    #                                    controlling_user_role_id: nil,
    #                                    controlling_for_user_role_id: nil,
    #                                    status_id: MoneyRequestStatus.id_for(:credited),
    #                                    payment: self.payment,
    #                                    processed_amount_attributes: {
    #                                        value: self.amount_credited,
    #                                        currency_id: Currency.first.id
    #                                    }
    #
    #   role_id = (self.user.finance_manager? and params.present? and finance_view?) ? UserRole.id_for(:finance_manager) : UserRole.id_for(:admin)
    #   money_request.tracks.create action_user: user,
    #                               action_user_role_id: role_id,
    #                               money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:credited),
    #                               status_id: MoneyRequestStatus.id_for(:credited),
    #                               payment: self.payment
    #
    # end

    ###################
    # NEW CODE
    #  Workflow Manager
    params[:document] = self.money_request
    params[:aasm_event] = 'mark_as_credited'
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
    if success?
      money_request.comments.create money_request_id: money_request.id,
                                    user: user,
                                    comment_action_id: MoneyRequestCommentAction.id_for(:credited),
                                    payment: self.payment
    end
  end
end