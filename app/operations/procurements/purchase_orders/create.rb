class Procurements::PurchaseOrders::Create < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :vendor, :template

  def init
    self.purchase_order_params = purchase_order_parameters
    self.procurement = user.company.procurements.find_by id: params[:procurement_id]
    vendor_id = purchase_order_params[:vendor_id]
    self.vendor = ::BankTransfer::Vendors::Index.(user, {without_bank_accounts: true}).vendors.with_ids(vendor_id).first rescue nil
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end

    unless self.vendor.present?
      add_message :error, 'Vendor not found'
      return
    end

    unless self.vendor.bank_accounts.present?
      add_message :error, "Vendor doesn't have a bank account, please add one before proceeding"
      return
    end

  end

  def process
    if params[:template_id].present?
      load_po_from_template
      self.purchase_order.procurement = self.procurement
    else
      self.purchase_order = procurement.build_purchase_order(purchase_order_params)
    end
    self.purchase_order.purchase_order_status_id = PurchaseOrderStatus.id_for(:open)
    self.purchase_order.user = user
    self.purchase_order.company = user.company
    self.purchase_order.controlling_user = user
    if self.vendor.payment_term_id.present?
      self.purchase_order.payment_term_id = self.vendor.payment_term_id
    end
    self.purchase_order.controlling_user_role_id = UserRole.id_for(:initiator)

    if purchase_order.valid?
      if purchase_order.save
        if params[:associated_resource] == "purchase_request_item"
          # Status transition of PR
          perform_status_transition({document_name: 'purchase_request', status_to: 'po_created', user: user, params: params})
          purchase_order.associate_purchase_request_items(params, user)
        end
      end
      purchase_order.process_line_item_calculation
      purchase_order.save

      # Create Trail for it
      purchase_order.trails.create action_user: user,
                                   action_id: TrailAction.id_for(:create)

      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
      self.procurement.status_tags << status_tag

      CustomField::SetFields.(purchase_order, FieldParentType.id_for(:purchase_order), reset_fields: true, save: true)

      # params[:purchase_order_id] = self.purchase_order.id
      # params[:receiving_user_type] = self.vendor.class&.name
      # params[:receiving_user_id] = self.vendor.bank_accounts.first.account_owner_id
      # params[:receiving_account_id] = self.vendor.id

    else
      add_message :error, purchase_order.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully created purchase order'
  end

  protected
  def load_po_from_template
    result = Procurements::PurchaseOrders::Templates::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.template
    self.purchase_order = self.template.resource.amoeba_dup
  end

  def perform_status_transition(options={})
    case options[:status_to]
    when :po_created, 'po_created'
      item_ids = self.purchase_order.filter_purchase_request_item_ids(params, user)
      document = ::PurchaseRequestItem.with_ids(item_ids).last.purchase_request rescue nil
      params[:document] = document
      params[:aasm_event] = 'po_creation'
      op = WorkflowManager::Base.(user, params) if document.present?
      unless op.success? || document.present?
        add_message :error, op.messages[:error]
        return
      end
      # Update Purchase request item statuses
      ::PurchaseRequestItem.with_ids(item_ids).update_all(status_id: ::PurchaseRequestItemStatus.id_for(:po_created))
    end
  end
end