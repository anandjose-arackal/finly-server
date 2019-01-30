class BankTransfer::Payments::AllPayments < BankTransfer::Payments::Base

  attr_accessor :payment_order_ids, :payments, :payment_orders

  def init
    # params[:with_application] = RequestStore.store[:current_app].to_s
    params[:filter_vendor_payments] = 1
  end

  def process
    if user.vendor_payments_admin?
      # all payments within a company - through the admin
      company_not_open = user.company.payment_orders.not_open.pluck(:id)
      personal_orders = user.payment_orders.pluck(:id)
      self.payment_orders = PaymentOrder.with_id(company_not_open + personal_orders)
    else
      # only payments initiated by this particular user
      self.payment_orders = user.payment_orders
    end

    self.payment_order_ids = self.payment_orders.pluck(:id)
    self.payments = Payment.with_payment_order_id(payment_order_ids)
  end

  def success
    params[:payments] = self.payments
    BankTransfer::Payments::Index::PaymentsPresenter.new(current_user, params)
  end

  class BankTransfer::Payments::Index::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments, :paginated_payments

    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_vendor_payments
    has_scope :filter_user_id
    has_scope :filter_search_index, using: [:beneficiary_type, :receiving_user_id], type: :hash
    has_scope :filter_payment_id
    has_scope :filter_receiving_user_name
    has_scope :filter_beneficiary_account_number
    has_scope :filter_beneficiary_account_ifsc
    has_scope :filter_initiating_user_name


    def init
      self.payments = params[:payments]
      self.payments = apply_scopes(params[:payments], params)
      self.paginated_payments = payments.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end
  end
end