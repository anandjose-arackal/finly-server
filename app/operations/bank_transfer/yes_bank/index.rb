class BankTransfer::YesBank::Index < BankTransfer::YesBank::Base
  attr_accessor :payment_orders, :role_id

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    self.role_id = params[:role_id]
    if self.role_id.blank? and params[:view].present?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
    params[:with_application] = RequestStore.store[:current_app].to_s unless current_device == :api
    params[:filter_vendor_payments] = '1'
  end

  def process
    case role_id
      when UserRole.id_for(:admin), UserRole.id_for(:auditor)
        company_not_open = user.company.payment_orders.not_open.pluck(:id)
        personal_orders = user.payment_orders.pluck(:id)
        self.payment_orders = PaymentOrder.where(id: (company_not_open + personal_orders))
      else
        # i.e. personal view
        self.payment_orders = user.payment_orders
      end
  end

  def success
    params[:payment_orders] = self.payment_orders
    BankTransfer::YesBank::Index::OrdersPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Index::OrdersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_orders, :paginated_payment_orders

    include HasScope

    # has_scope :with_application
    has_scope :filter_vendor_payments
    has_scope :filter_date, using: [:from, :to], type: :hash

    def init
      self.payment_orders = params[:payment_orders]
      self.payment_orders = apply_scopes(payment_orders, params) if payment_orders.present?
      self.paginated_payment_orders = payment_orders.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end
  end


end


