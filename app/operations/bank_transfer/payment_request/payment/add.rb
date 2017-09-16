# this operation adds code to add a particular payment to a bank payment request
# The bank accounts are added as follows:
# params:
# bank_accounts: []
#   {
#      id: 2,
#      amount: 200
#   },
#   .
#   .
#   .
#   .
# ]

class BankTransfer::PaymentRequest::Payment::Add < BankTransfer::PaymentRequest::Base

  attr_accessor :payments_data, :amount, :bank_payment_request, :payment_order,
                :error_messages

  def pre_validate
    super
    if params[:bank_accounts].blank?
      add_message :error, "No bank accounts data passed"
    end
  end

  def init
    super
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
    # self.bank_payment_request = BankPaymentRequest.find_by(id: id)
    self.payment_order = bank_payment_request.payment_order
    self.payments_data = []
    params[:bank_accounts].each do |bank_account|
      id = bank_account[:id]
      bank_account = user.company.bank_accounts.find_by(id: id)
      self.payments_data << {
          initiating_account: bank_payment_request.payment_order.initiating_account,
          receiving_account: bank_account,
          receiving_user: bank_account.account_owner,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payments),
          payment_mode: bank_payment_request.payment_order.payments.first.payment_mode,
          amount_attributes: {
              value: bank_account[:amount],
              currency_id: 1
          },
          date: (bank_payment_request.payment_order.scheduled_at || DateUtils.local_date)
      }
    end
  end

  def validate
    super

    # checking if the payment data is valid - all or nothing
    # todo - the error messages can be customized to each payment being added later - like in multiple expense creation
    valid = true
    self.error_messages = []
    self.payments_data.each do |data|
      payment = self.payment_order.payments.build(data)
      unless payment.valid?
        valid = false
        error_messages << payment.error.full_messages.to_sentence
      end
    end
    unless valid
      add_message :error, error_messages.to_sentence
    end
  end

  def process
    self.payments_data.each do |data|
      payment = self.payment_order.payments.build(data)
      payment.save
    end
  end

  def post_process
    add_message :error, "Beneficiaries added!"
  end


end