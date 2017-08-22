class BankTransfer::YesBank::Count < BankTransfer::YesBank::Base
  attr_accessor :payment_orders_count

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init

  end

  def process
    pos = BankTransfer::YesBank::Index.(user, params)
    self.payment_orders_count = pos.payment_orders.count
  end

  def success
    payment_orders_count
  end


end


