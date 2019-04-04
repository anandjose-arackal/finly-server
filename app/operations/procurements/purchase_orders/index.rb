class Procurements::PurchaseOrders::Index < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :policies
  def init

  end

  def validate

  end

  def process
    # # Only used for getting pending approval
    # if user.vendor_payments_reviewer?
    #   self.purchase_orders = PurchaseOrder.awaiting_action_items(user)
    # end


    if user.vp_admin_or_auditor?
      admin_restricted_status_ids = [PurchaseOrderStatus.id_for(:open)]
      self.purchase_orders = ::PurchaseOrder.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.purchase_orders)
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.purchase_orders = ::PurchaseOrder.associated_items(user, ::PurchaseOrder.roles) || PurchaseOrder.none
    else
      self.purchase_orders = user.purchase_orders
    end
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Procurements::PurchaseOrders::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders

    has_scope :filter_awaiting_approval
    has_scope :filter_month
    has_scope :filter_year
    has_scope :filter_user
    has_scope :filter_vendor_id

    def init
      self.purchase_orders = params[:purchase_orders]
      self.purchase_orders = apply_scopes(self.purchase_orders, params)
    end
  end
end