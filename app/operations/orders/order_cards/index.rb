class Orders::OrderCards::Index < Orders::OrderCards::Base
  attr_accessor :payment_orders, :params_order_cards, :role_id

  def authorized_user_types
    [:company_admin, :auditor, :finance_manager]
  end

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.params_order_cards = order_cards_params
    self.role_id = params[:role_id]
    if self.role_id.blank?
      self.role_id = UserRole::VALUES[params[:view].to_sym]
    end
    # this is to ensure only payment orders that are processed from the disburse panel show up
    params[:with_application] = RequestStore.store[:current_app].to_s
  end

  def process
    case self.role_id
      when UserRole.id_for(:admin)
        self.payment_orders = user.company.payment_orders
      when UserRole.id_for(:finance_manager)
        self.payment_orders = user.payment_orders
      else
        # by default it just returns payment orders initiated by this user
        self.payment_orders = user.payment_orders
    end
  end

  def success
    params[:payment_orders] = self.payment_orders
    Orders::OrderCards::Index::SuccessPresenter.new(user, params, messages)
  end

  class Orders::OrderCards::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_orders, :paginated_payment_orders, :count

    include HasScope

    has_scope :with_application

    def init
      self.payment_orders = params[:payment_orders]
      self.payment_orders = apply_scopes(payment_orders, params)
      self.count = self.payment_orders.count
      self.paginated_payment_orders = self.payment_orders&.paginate(page: params[:page], per_page: 30)
    end
  end
end