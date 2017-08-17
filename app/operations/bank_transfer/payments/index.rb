# his will give an index of the set of individual payments done from the company's end
# will later be scoped based on the user role

class BankTransfer::Payments::Index < BankTransfer::Payments::Base

  attr_accessor :payment_order_ids, :payments

  def init
    params[:with_application] = RequestStore.store[:current_app].to_s
  end

  def process
    op = BankTransfer::YesBank::Index.(current_user, params)
    if op.success?
      self.payment_order_ids = op.payment_orders.pluck(:id)
    else
      add_message :error, op.messages[:error]
    end
    self.payments = Payment.with_payment_order_id(payment_order_ids)
  end

  def success
    params[:payments] = self.payments
    BankTransfer::Payments::Index::PaymentsPresenter.new(current_user, params)
  end

  class BankTransfer::Payments::Index::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments

    has_scope :with_application
    has_scope :filter_search
    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.payments = apply_scopes(params[:payments], params)
    end
  end
end