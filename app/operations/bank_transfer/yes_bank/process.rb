# this extracts the payment data from the parsed excel file and creates the payment
# request object out of it
class BankTransfer::YesBank::Process < BankTransfer::YesBank::Base
  attr_accessor :payment_order_data, :processed_order, :requested_amount, :processable_amount,
                :errors, :payment_order_valid, :scheduled_at

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    self.payment_order_data = params[:payment_order]
    self.errors = []
    self.payment_order_valid = true # setting it true here for now, so that if it fails later that can be taken up
    self.requested_amount = 0
    self.processable_amount = 0
    self.processed_order = []
    self.scheduled_at = Date.parse params[:scheduled_at] if params[:scheduled_at].present? and DateUtils.validate_date_format?(params[:scheduled_at])

    if scheduled_at.present? and scheduled_at < Date.today
      self.scheduled_at = Date.today
    end

    od = []
    if payment_order_data.is_a?(Hash)
      payment_order_data.each do |key, value|
        od << value
      end
      self.payment_order_data = od
    end
  end

  def validate
    if payment_order_data.blank?
      self.errors << 'Error loading order details'
      return
    end

    # todo - change this to the adapter method of finding the company balance
    company_balance = 99999

    payment_order_data.each do |item|
      self.requested_amount += (item[:amount].to_d rescue 0)
    end

    if self.requested_amount > company_balance
      self.errors << 'Insufficient funds to initiate the transfer'
      self.payment_order_valid = false
    end

  end

  def process

    if payment_order_data.is_a?(Hash)
      arr = []
      self.payment_order_data.map {|k, v| arr << v }
      self.payment_order_data = arr
    end

    self.payment_order_data.each do |item|
      bank_account_no = item[:account_number]
      ifsc = item[:ifsc]
      name = item[:name]
      amount = item[:amount]&.to_f

      valid = true
      messages = []

      # Check if bank account number is present
      if bank_account_no.blank?
        valid = false
        messages << 'Bank account not found'
      end

      # Check if the amount is present
      if amount.blank? || !amount.is_a?(Numeric)
        valid = false
        messages << 'Invalid amount'
      end

      # check if name is present
      if name.blank?
        valid = false
        messages << 'Name cannot be blank'
      end

      # check if the ifsc is present
      if ifsc.blank?
        valid = false
        messages << 'IFSC cannot be blank'
      end

      # todo - if there's any user specific configuration for this particular user,
      # add it here

      if valid
        self.processable_amount += amount
      end

      self.payment_order_valid = false unless valid

      self.processed_order << {bank_account_no: bank_account_no, ifsc: ifsc, name: name, amount: amount, valid: valid, messages: messages}
    end
  end

  def success
    params[:payment_order_data] = self.payment_order_data
    params[:processed_order] = self.processed_order
    params[:requested_amount] = self.requested_amount
    params[:processable_amount] = self.processable_amount
    params[:errors] = self.errors
    params[:payment_order_valid] = self.payment_order_valid
    params[:scheduled_at] = self.scheduled_at
    BankTransfer::YesBank::Process::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Process::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order_data, :processed_order, :requested_amount, :processable_amount, :errors,
                  :payment_order_valid, :scheduled_at

    def init
      self.payment_order_data = params[:payment_order_data]
      self.processed_order = params[:processed_order]
      self.requested_amount = params[:requested_amount]
      self.processable_amount = params[:processable_amount]
      self.errors = params[:errors]
      self.payment_order_valid = params[:payment_order_valid]
      self.scheduled_at = params[:scheduled_at]
    end

    def scheduled_at_formatted
      DateUtils.date_formatted self.scheduled_at
    end

    def created_at_formatted
      DateUtils.date_formatted Date.today
    end

  end

end
