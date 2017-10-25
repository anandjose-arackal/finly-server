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

  end

  def pre_process

  end

  def process
    self.payment_receivable = company.payment_receivables.build(payment_receivable_params)
    if self.payment_receivable.save
      # now create a virtual bank account for this receivable and attach it to the current object
      op = Invoicing::VirtualBankAccount::Create.(user, {parent: self.payment_receivable,
                                                         purpose_id: VirtualAccountPurpose.id_for(:payment_receivable)})
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