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
      return
    end
  end

  def process
    result = Card::Funds::Transfer.(user, to_user: self.to_user, amount: self.amount)
    unless result.success?
      add_message :error, result.messages[:error]
    end
  end

  def post_process
    add_message :success, 'Funds transferred successfully!'
  end

end
