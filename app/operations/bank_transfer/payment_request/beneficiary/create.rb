# this operation adds a particular vendor from the payment order screen and adds him or her as
# a beneficiary to the payment request

class BankTransfer::PaymentRequest::Beneficiary::Create < BankTransfer::PaymentRequest::Beneficiary::Base

  attr_accessor :vendor_params, :company

  def pre_validate
    super
    if params[:yes_bank_vendor].blank?
      add_message :error, "Invalid parameters, try again later"
    end
  end

  def init
    super
    self.company = user.company
    self.vendor_params = vendor_parameters
    self.amount = params[:yes_bank_vendor][:amount].to_f
  end

  def validate
    super
    if self.amount.blank?
      add_message :error, "Amount cannot be empty"
    end
  end

  def process
    self.vendor = company.yes_bank_vendors.build(self.vendor_params)
    if vendor.save
      # now add the respective bank account to the payment order as a beneficiary
      # create_payment
      self.payment_order.payments.build(
         payment_type_id: PaymentType.id_for(:credit),
         initiating_user: payment_order.initiating_user,
         receiving_user: self.vendor,
         initiating_account: user.bank_wallet,
         receiving_account: vendor.bank_accounts.order(created_at: :desc).first, # i.e. the latest created bank account
         payment_status_id: PaymentStatus.id_for(:pending_approval),
         payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
         payment_mode: payment_order.payment_mode
      )
    end
  end


  private

  def vendor_parameters
    params.require(:vendor).permit(:name, :email, :mobile_number, :authorized,
                                   bank_accounts_attributes: [:account_number, :ifsc, :name, :address_1, :address_2, :address_3, :pin_code, :country])
  end

  def create_payment

  end
end