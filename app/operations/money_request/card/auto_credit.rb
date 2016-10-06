class MoneyRequest::Card::AutoCredit < MoneyRequest::Base
  attr_accessor :money_request, :amount

  def pre_validate
    if params[:money_request].blank? or not params[:money_request].is_a?(MoneyRequest)
      messages[:error] << 'Error loading advance request'
      return
    end
    unless  params[:money_request].payment_mode.id == PaymentMode.id_for(:card)
      messages[:error] << 'Cannot load the card as the selected payment mode is cash'
    end
  end

  def init
    self.money_request = params[:money_request]
    self.amount = money_request.total_amount
  end

  def validate
    if amount <= 0
      messages[:error] << 'Nothing to credit as the requested amount is equal to 0'
    end
  end

  def process
    result = ItzCash::Credit.(money_request.user, amount: self.amount)
    if result.success?
      update_attr = {}
      update_attr[:status_id] = MoneyRequestStatus.id_for(:credited)
      update_attr[:controlling_user_id] = nil
      update_attr[:controlling_for_user_id] = nil
      update_attr[:controlling_user_role_id] = nil
      update_attr[:controlling_for_user_role_id] = nil
      money_request.update_attributes update_attr

      track_attr = {}
      track_attr[:action_user] = nil
      track_attr[:money_request_tracking_action_id] = MoneyRequestTrackingAction.id_for(:credited)
      track_attr[:status_id] = MoneyRequestStatus.id_for(:credited)
      track_attr[:modified_user] = nil
      track_attr[:modified_user_role_id] = nil
      money_request.tracks.create track_attr

      comment_attr = {}
      comment_attr[:comment_action_id] = MoneyRequestCommentAction.id_for(:credited)
      money_request.comments.create comment_attr
    else
      messages[:error] = result.messages[:error]
    end
  end

  def post_process
    messages[:success] << 'Money Request credited successfully'
  end

end
