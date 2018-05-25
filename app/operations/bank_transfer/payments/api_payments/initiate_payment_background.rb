# this operation will add all payments to the bank payment request passed and
# once done will initiate the payments one by one in the background itself

# Accepts: BankPaymentRequest object and individual payments hash

class BankTransfer::Payments::ApiPayments::InitiatePaymentBackground < BankTransfer::Payments::Base

  attr_accessor :bank_payment_request, :payments_attributes, :payment_mode

  def self.call(user, options = {})
    self.new.perform(user, options)
  end

  def perform(user, options, request_store_hash = nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.bank_payment_request = options[:bank_payment_request]
    self.payments_attributes = options[:payments_attributes]
    self.payment_mode = options[:payment_mode]
    self.options = options
    self.run
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options
  end

  def pre_validate

  end

  def init
    # here assign attributes to the existing bank payment request object which can be saved later
    payment_params = []
    self.payments_attributes.each do |payment|
      bank_account = retrieve_bank_account(payment)
      payment_params << {
          payment_type_id: PaymentType.id_for(:credit),
          application: "vp",
          receiving_user_type: bank_account.account_owner.class.name,
          receiving_user_id: bank_account.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: YesBankCompanyAccount.name,
          initiating_account_id: user.company.yes_bank_company_account.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: self.bank_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          payment_mode: self.payment_mode,
          amount_attributes: {
              value: payment[:amount],
              currency_id: Currency.first.id
          },
          note: payment[:note],
          date: DateUtils.local_date,
      }
    end
    self.bank_payment_request.payment_order.payments.build(payment_params)
    # now create the bank payment request object and save it so that
    self.bank_payment_request.save
  end

  def validate

  end

  def process
    # now that we have the bank payment request and the payments saved and ready to execute,
    # we can call the payment order executor that will credit each payment one by one
    payment_order = self.bank_payment_request.payment_order
    BankTransfer::YesBank::Execute.call(payment_order.initiating_user, payment_order_id: payment_order.id)
  end

end