class MoneyRequest::MarkAsCredited < MoneyRequest::Base
  attr_accessor :payment, :money_requests

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def init
    self.money_request = (params[:money_request] or params[:money_requests])
    self.payment = params[:payment]
  end

  def validate
    unless money_request.payment_pending?
      messages[:error] << 'Money Request cannot be credited at this stage'
    end
  end

  def process
    if money_request.update_attributes controlling_user: nil, controlling_for_user: nil,
                                       money_request_status_id: MoneyRequestStatus.id_for(:credited), memo: nil
      money_request.tracks.create action_user: user, money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:credited),
                                  money_request_status_id: MoneyRequestStatus.id_for(:credited)
    end
  end

  def post_process
    if success?
      money_request.comments.create user: user, money_request_comment_action_id: MoneyRequestCommentAction.id_for(:credited)
    end
  end
end