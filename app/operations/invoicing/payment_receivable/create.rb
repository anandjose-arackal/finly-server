# can create a payment receivable for an existing customer, or create a customer
# on the fly. Will call the Create Virtual Account operation to create the account from
# the FinlyCollect server

class Invoicing::PaymentReceivable::Create < Invoicing::PaymentReceivable::Base

  attr_accessor :payment_receivable, :payment_receivable_params, :company

  def init
    self.payment_receivable_params = receivable_params
    self.company = user.company
  end

  def validate
    if Date.parse(payment_receivable_params[:expire_by]) < DateUtils.local_date
      add_message :error, "Expiry date cannot be the in the past"
    end
  end

  def pre_process
    self.payment_receivable_params[:payment_receivable_status_id] = PaymentReceivableStatus.id_for(:active)
    self.payment_receivable_params[:initiating_user_id] = user.id
  end

  def process
    self.payment_receivable = company.payment_receivables.build(payment_receivable_params)
    if self.payment_receivable.save
      # now create a virtual bank account for this receivable and attach it to the current object
      op = Invoicing::VirtualBankAccount::Create.(user, {parent: self.payment_receivable,
                                                         purpose_id: VirtualAccountPurpose.id_for(:payment_receivable),
                                                         exact_transaction_amount: self.payment_receivable.amount_value,
                                                         date_before: self.payment_receivable.expire_by})
    else
      add_message :error, payment_receivable.errors.full_messages
      return
    end
  end

  private

  def receivable_params
    params.require(:payment_receivable).permit(:purpose, :expire_by, :initiating_user_id, :customer_id,
                                               amount_attributes: [:value, :currency_id],
                                               customer_attributes: [:email, :mobile_number, :name, :description]
                                              )
  end
end