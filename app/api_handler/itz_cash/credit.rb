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
    end
  end

  def path
    '/user/servlet/NaradaCreditDebitServlet'
  end

  def post_params
    # serial_id = user.cards.first.serial_id
    serial_id = 'S00017740090'
    {serialid: serial_id, itzmodule: Constants::ItzCash::MODULE, dcode: Constants::ItzCash::DUMMY_DCODE,
     merchanttypekey: Constants::ItzCash::MERCHANT_TYPE_KEY,
     reftransid: Generator.new_transaction_id, productcode: Constants::ItzCash::PRODUCT_CODE, amount: amount,
     transactiontype: transaction_type}
  end

  def transaction_type
    Constants::ItzCash::TRANSACTION_TYPE_CREDIT
  end

  def init
    super
    self.amount = params[:amount].to_i rescue nil
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
    # todo record the credit in our database
  end

  def success
    # ResponseCode,SerialID,Amount,TransactionID,Message
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:amount]=parsed_response[2]
    params[:transaction_id]= parsed_response[3]
    params[:message]= parsed_response[4]
    ItzCash::Credit::SuccessPresenter.new(self.user, params, messages)
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