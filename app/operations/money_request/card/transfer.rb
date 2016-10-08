class MoneyRequest::Card::Transfer < MoneyRequest::Base
  attr_accessor :to_user, :amount

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if user.cards.blank?
      add_message :error, 'Card is not assigned to the user to transfer the funds'
      return
    end
    if params.blank? or params[:amount].blank? or params[:amount].to_i <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
      return
    end
    if params[:money_request_id].blank?
      add_message :error, 'Request not found to initiate the transfer'
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid password!'
    end
  end

  def init
    super
    return if self.money_request.blank?
    self.to_user = money_request.user
    return if to_user.blank?
    self.amount = params[:amount].to_i
  end

  def validate
    super
    if money_request.controlling_user != user.id
      add_message :error, 'You do not have the permission to transfer the funds'
    end
    unless money_request.processing?
      add_message :error, 'The advance request cannot be credited as it is not in processing state'
    end
    if to_user.blank?
      add_message :error, 'User not found to transfere the funds to!'
      return
    end
    if to_user.cards.blank?
      add_message :error, 'Card is not assigned to the user to receive funds'
    end
  end

  def process
    result = transfer
    if result.success?
      update_attributes = {}
      update_attributes[:status_id] = MoneyRequestStatus.id_for(:credited)
      update_attributes[:controlling_user_id] = nil
      update_attributes[:controlling_for_user_id] = nil
      update_attributes[:controlling_user_role_id] = nil
      update_attributes[:controlling_for_user_role_id] = nil
      update_attributes[:memo] = self.params[:memo]
      money_request.update_attributes update_attributes

      track_attributes = {}
      track_attributes[:action_user] = user
      track_attributes[:money_request_tracking_action_id] = MoneyRequestTrackingAction.id_for(:credited)
      track_attributes[:status_id] = MoneyRequestStatus.id_for(:credited)
      track_attributes[:payment] = result.payment
      money_request.tracks.create track_attributes

      money_request.comments.create money_request_id: money_request.id,
                                    user: user, comment_action_id: MoneyRequestCommentAction.id_for(:credited), payment: result.payment
    else
      add_message :error, result.messages[:error]
    end
  end

  def post_process
    add_message :success, 'Funds transferred successfully!'
  end

  protected
  def transfer
    Card::Funds::Transfer.(user, to_user: self.to_user, amount: self.amount, password: params[:password])
  end

end
