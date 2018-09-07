class Procurements::Invoices::Create < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params, :vendor

  def init
    self.invoice_params = invoice_parameters
    self.procurement = user.company.procurements.find_by id: params[:procurement_id]
    vendor_id = invoice_params[:vendor_id]
    self.vendor = ::BankTransfer::Vendors::Index.(user, {without_bank_accounts: true}).vendors.with_ids(vendor_id).first rescue nil
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end

    unless self.vendor.present?
      add_message :error, 'Vendor not found'
    end
  end

  def process
    self.purchase_order = procurement.build_purchase_order(purchase_order_params)
    self.purchase_order.purchase_order_status_id = PurchaseOrderStatus.id_for(:open)
    self.purchase_order.user = user
    self.purchase_order.company = user.company
    self.purchase_order.controlling_user = user
    if self.vendor.payment_term_id.present?
      self.purchase_order.payment_term_id = self.vendor.payment_term_id
    end

    role_id = UserRole.id_for(:initiator)
    self.purchase_order.controlling_user_role_id = role_id

    if purchase_order.valid?
      purchase_order.save

      # Create Trail for it
      purchase_order.trails.create action_user: user,
                                   action_id: TrailAction.id_for(:create)

      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
      self.procurement.status_tags << status_tag

      CustomField::SetFields.(purchase_order, FieldParentType.id_for(:purchase_order), reset_fields: true, save: true)

    else
      add_message :error, purchase_order.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully created purchase order'
  end
end