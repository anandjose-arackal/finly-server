class MoneyRequest::PrepaidCard::Credit < MoneyRequest::Base
  attr_accessor :to_user, :amount

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params.blank? or (params[:money_request_id].blank? and params[:id].blank?)
      add_message :error, 'Request not found to initiate the transfer'
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid password!'
    end
    if params[:from_account].blank?
      add_message :error, 'From Account not defined'
      return
    end
    unless params[:from_account].to_sym == :wallet or params[:from_account].to_sym == :virtual_account
      add_message :error, 'Invalid account type'
    end
    if params[:to_account].present? and not params[:to_account].to_sym == :card and not params[:to_account].to_sym == :wallet
      add_message :error, 'Invalid transfer to account type'
    end
  end

  def init
    super
    return if self.money_request.blank?
    self.to_user = money_request.user
    return if to_user.blank? or money_request.blank?
    self.amount = money_request.total_amount
  end

  def validate
    super
    if money_request.controlling_user.id != user.id
      add_message :error, 'You do not have the permission to transfer the funds'
    end
    unless money_request.processing?
      add_message :error, 'The advance request cannot be credited as it is not in processing state'
    end
    if to_user.blank?
      add_message :error, 'User not found to transfer the funds!'
      return
    end
    if self.amount.blank?
      add_message :error, 'Amount cannot be less than 0'
    end
    if to_user.cards.blank?
      add_message :error, 'Card is not assigned to the user to receive funds'
    end
    if amount.nil? or not (amount.is_a?(BigDecimal) or amount.is_a?(Float))
      add_message :error, 'Error processing request'
    end
  end

  def process
    if amount > 0
      from_account = params[:from_account].to_sym
      to_account = :card
      to_account = params[:to_account].to_sym if params[:to_account].present?
      result = User::Wallet::Credit.(user, from_account: from_account, to_account: to_account, to_user: to_user, amount: self.amount, password: params[:password])
      if result.failure?
        add_message :error, result.messages[:error]
        return
      end

      role_id = money_request.controlling_user_role_id

      update_attributes = {}
      update_attributes[:status_id] = MoneyRequestStatus.id_for(:credited)
      update_attributes[:controlling_user_id] = nil
      update_attributes[:controlling_for_user_id] = nil
      update_attributes[:controlling_user_role_id] = nil
      update_attributes[:controlling_for_user_role_id] = nil
      update_attributes[:payment] = result.payment

      money_request.update_attributes update_attributes

      track_attributes = {}
      track_attributes[:action_user] = user
      track_attributes[:action_user_role_id] = role_id
      track_attributes[:money_request_tracking_action_id] = MoneyRequestTrackingAction.id_for(:credited)
      track_attributes[:status_id] = MoneyRequestStatus.id_for(:credited)
      track_attributes[:payment] = result.payment
      money_request.tracks.create track_attributes

      action_id = "credited_from_#{from_account}_to_#{to_account}"
      money_request.comments.create money_request_id: money_request.id,
                                    user: user, comment_action_id: MoneyRequestCommentAction.id_for(action_id.to_sym), payment: result.payment
    end
  end

  def post_process
    add_message :success, 'Funds transferred successfully'
  end

end