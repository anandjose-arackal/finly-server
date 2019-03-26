# Fetches purchase orders which have an advance amount attribute set to it.
# Not to be confused with advance payment, which we create later
# We return only those purchase orders for processing which have the advance amount status set as TO_BE_PROCESSED and FAILED
# cheers!

class Procurements::PurchaseOrders::PoWithAdvance < Procurements::PurchaseOrders::Base

  attr_accessor :purchase_orders

  class Procurements::PurchaseOrders::PoWithAdvance::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :purchase_order, :paginated_purchase_order

    has_scope :filter_by_due_date
    has_scope :filter_po_number
    has_scope :filter_vendor_id
    has_scope :filter_by_created_at
    has_scope :filter_payable_advances
    has_scope :filter_user_id
    has_scope :filter_status
    # These two filters created because two different indexes requires data to be handles differently by design
    has_scope :po_advances_date, using: [:from, :to], type: :hash
    has_scope :due_date, using: [:from, :to], type: :hash



    def init
      self.purchase_order = params[:purchase_order]
      self.purchase_order = apply_scopes(self.purchase_order, params)
      self.paginated_purchase_order = self.purchase_order.paginate(page: params[:page], per_page: (params[:per_page] || 30))
    end


    def get_status_counts
      raw_count = self.purchase_order.where.not(advance_amount_status_id: nil).group(:advance_amount_status_id).count
      h = {}
      AdvanceAmountStatus.all.each {|ps| if raw_count.keys.include? ps.id then h[ps.name] = raw_count[ps.id] else h[ps.name] = 0 end}
      h.delete("po_processing") # for now we would only be showing advances where po are only auto/approved
      return h
    end

  end

  def init
    if user.vp_admin_or_auditor?
      admin_restricted_status_ids = [PurchaseOrderStatus.id_for(:open)]
      self.purchase_orders = PurchaseOrder.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).or(user.purchase_orders)
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.purchase_orders = PurchaseOrder.associated_items(user, resource_roles= ::PurchaseOrder.roles) rescue ::Procurement.none
    end
    
  end

  def validate

    # reject_po = []
    # self.purchase_orders.each do |purchase_order|
    #   valid = true
    #   if purchase_order.advance_payments.present?
    #     valid = false
    #     if purchase_order.advance_amount_status_id == AdvanceAmountStatus.id_for(:failed)
    #       valid = true
    #     end
    #   end

    #   unless valid
    #     reject_po << purchase_order
    #   end
    # end

    # self.purchase_orders = self.purchase_orders.reject do |all_po|
    #     reject_po.any? do |po|
    #         all_po.id == po.id
    #     end
    # end

    # if self.purchase_orders.blank?
    #   add_message :error, "Purchase order with advance amount still to be processed or failed, were not found."
    # end
  end

  def process
    self.purchase_orders = purchase_orders.filter_all_advances #unless self.purchase_orders.blank?
    params[:purchase_order] = self.purchase_orders
  end

  def success    
    Procurements::PurchaseOrders::PoWithAdvance::PaymentsPresenter.new(user, params, messages)
  end
end