# his will give an index of the set of individual payments done from the company's end
# will later be scoped based on the user role

class BankTransfer::Payments::Index < BankTransfer::Payments::Base

  attr_accessor :payment_order_ids, :payments

  def init
    params[:with_application] = RequestStore.store[:current_app].to_s
    params[:filter_vendor_payments] = 1
  end

  def process
    op = BankTransfer::YesBank::Index.(current_user, params)
    if op.success?
      self.payment_order_ids = op.payment_orders.pluck(:id)
    else
      add_message :error, op.messages[:error]
      return
    end
    self.payments = Payment.with_payment_order_id(payment_order_ids)
  end

  def success
    params[:payments] = self.payments
    BankTransfer::Payments::Index::PaymentsPresenter.new(current_user, params)
  end

  class BankTransfer::Payments::Index::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments, :paginated_payments

    has_scope :with_application
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_vendor_payments
    has_scope :filter_user_id
    has_scope :filter_search_index, using: [:beneficiary_type, :receiving_user_id], type: :hash
    has_scope :filter_payment_id
    has_scope :filter_receiving_user_name
    has_scope :filter_beneficiary_account_number
    has_scope :filter_beneficiary_ifsc
    has_scope :filter_initiating_user_name


    def init
      self.payments = params[:payments]
      self.payments = apply_scopes(params[:payments], params)
      self.paginated_payments = payments.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end
  end
end