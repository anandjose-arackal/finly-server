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

  attr_accessor :payments_data, :amount

  def pre_validate
    super
    if params[:bank_accounts].blank?
      add_message :error, "No bank accounts data passed"
    end
  end

  def init
    super
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
end