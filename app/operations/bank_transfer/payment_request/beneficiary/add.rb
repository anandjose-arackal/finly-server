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

class BankTransfer::PaymentRequest::Beneficiary::Add < BankTransfer::PaymentRequest::Beneficiary::Base

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
    self.payments_data = []
    params[:bank_accounts].each do |bank_account|
      id = bank_account[:id]
      account = user.company.bank_accounts.find_by(id: id)
      initiating_account = bank_payment_request.payment_order.initiating_account || user.bank_wallet
      self.payments_data << {
          initiating_account: initiating_account,
          receiving_account: account,
          receiving_user: account.account_owner,
          initiating_user: user,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_type_id: PaymentType.id_for(:credit),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payments),
          payment_mode: bank_payment_request.payment_order.payment_mode,
          amount_attributes: {
              value: bank_account[:amount],
              currency_id: 1
          },
          date: (bank_payment_request.payment_order.scheduled_at || DateUtils.local_date),
          invoice_attributes: {
              original_amount_attributes: {
                  value: 0,
                  currency_id: 1
              },
              freight_amount_attributes: {
                  value: 0,
                  currency_id: 1
              },
              gross_amount_attributes: {
                  value: 0,
                  currency_id: 1
              },
              amount_attributes: {
                  value: 0,
                  currency_id: 1
              },
              net_amount_attributes: {
                  value: 0,
                  currency_id: 1
              }
          }
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
        error_messages << payment.errors.full_messages.to_sentence
      end
      # adding validations for custom fields here
    end
    unless valid
      add_message :error, error_messages.to_sentence
    end
  end

  def process
    self.payments_data.each do |data|
      payment = self.payment_order.payments.build(data)
      # set custom field data
      set_custom_fields(false, payment)
      payment.save
    end
  end

  def post_process
    add_message :success, "Beneficiaries added!"

    # update the amount requested for this particular payment order
    amount_requested = self.payment_order.request_total
    payment_order.amount_requested&.update(value: amount_requested)

    if bank_payment_request.retracted? || bank_payment_request.rejected?
      # adding comments for all the beneficiaries removed in the comments
      params[:bank_accounts].each do |data|
        id = data[:id]
        account = user.company.bank_accounts.find_by(id: id)
        bank_payment_request.comments.build(action_id: BankPaymentRequestCommentAction.id_for(:add_beneficiary),
                                            user_id: user.id,
                                            beneficiary_id: account.id).save
      end
    end
  end

  private

  def set_custom_fields(save, payment)
    fields = {}
    current_company.field_configurations.with_parent_type(FieldParentType.id_for(:invoice)).each do |fc|
      fields[fc.id] = ""
    end
    if fields.blank?
      return
    end
    custom_fields = {custom_fields: fields}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

end
