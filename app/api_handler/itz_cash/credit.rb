class ItzCash::Credit < ItzCash::Base
  attr_accessor :amount

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

  def init
    super
    self.amount = params[:amount].to_i rescue nil
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

  def parse

  end

end