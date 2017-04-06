class ItzCash::Credit < ItzCash::Base
  attr_accessor :amount

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.cards.blank?
      add_message :error, 'A card has not been assigned to the user'
      return
    end
    if params.blank? or params[:amount].blank?
      add_message :error, 'Amount cannot be blank'
      return
    end
    if params[:card_id].blank? or user.cards.with_id(params[:card_id]).blank?
      add_message :error, 'Card not found'
      return
    end
    if user.company.d_code.blank?
      add_message :error, 'Company has not been configured to initiate the transfer'
    end
  end

  def env_key
    'itzcash_credit_debit'
  end

  def post_params
    card = user.cards.with_id(params[:card_id]).first
    serial_id = card.serial_id
    {serialid: serial_id, itzmodule: Constants::ItzCash::MODULE, dcode: user.company.d_code,
     merchanttypekey: merchant_type_key,
     reftransid: Generator.new_transaction_id, productcode: card.product_code, amount: amount,
     transactiontype: transaction_type}
  end

  def merchant_type_key
    Constants::ItzCash::MERCHANT_TYPE_KEY_CREDIT
  end

  def transaction_type
    Constants::ItzCash::TRANSACTION_TYPE_CREDIT
  end

  def init
    super
    self.amount = params[:amount].to_d rescue nil
    # Convert amount value in paise
    self.amount = (self.amount * 100) if self.amount
  end

  def validate
    if self.amount.blank?
      add_message :error, 'Amount cannot be blank'
      return
    end
    if self.amount <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
  end

  def post_process

  end

  def success
    # ResponseCode,SerialID,Amount,TransactionID,Message
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:amount] = parsed_response[2]
    params[:transaction_id]= parsed_response[3]
    params[:message]= parsed_response[4]
    ItzCash::Credit::SuccessPresenter.new(self.user, params, messages)
  end

  def failure
    # Check if credit failed because amount is greater than remaining eligibility
    if self.parsed_response.present? and (parsed_response[0] == -3004 or parsed_response[0] == '-3004')
      response = ItzCash::AccountDetails.(user, params)
      if response.success? and response.available_card_eligibility < (self.amount / 100)
        if response.available_card_eligibility < 1
          add_message :error, 'Card has reached its maximum transferable limit'
        else
          add_message :error, "The given amount exceeds the eligibility limit of the card. You can only transfer upto ₹#{response.available_card_eligibility}"
        end
      end
    end
    super
  end

  def success_response_code
    [0, 2, 300, 301, 302]
  end

  class ItzCash::Credit::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :serial_id, :amount, :transaction_id, :message

    def init
      self.response_code = params[:response_code]
      self.serial_id = params[:serial_id]
      self.amount = params[:amount]
      self.transaction_id = params[:transaction_id]
      self.message = params[:message]
    end

  end

end