class Procurements::Invoices::Create < Procurements::Invoices::Base
  attr_accessor :invoice, :procurement, :invoice_params, :vendor, :template

  def init
    # self.invoice_params = invoice_parameters
    self.procurement = user.company.procurements.find_by id: params[:procurement_id]
    vendor_id = params[:purchase_order][:vendor_id] || params[:invoice][:vendor_id]
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

    if params[:template_id].present?
      load_invoice_from_template
      self.invoice.procurement = self.procurement
    else
      self.invoice = procurement.invoices.build
    end
    receiving_account = self.vendor&.bank_accounts&.first # todo - change this later to the one selected at the time of initiating payment
    self.invoice.invoice_status_id = InwardInvoiceStatus.id_for(:open)
    self.invoice.created_by = user
    self.invoice.company = user.company
    self.invoice.invoice_type_id = ::InwardInvoiceType.id_for(:tax_invoice)
    self.invoice.receiving_account = receiving_account
    self.invoice.controlling_user = user
    self.invoice.vendor = vendor
    if self.vendor.payment_term_id.present?
      self.invoice.payment_term_id = self.vendor.payment_term_id
    end

    role_id = UserRole.id_for(:initiator)
    self.invoice.controlling_user_role_id = role_id

    if invoice.valid?
      invoice.save

      # Create Trail for it
      invoice.trails.create action_user: user,
                                   action_id: TrailAction.id_for(:create)

      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_processing))
      self.procurement.status_tags << status_tag

      CustomField::SetFields.(invoice, FieldParentType.id_for(:invoice), reset_fields: true, save: true)

    else
      add_message :error, invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully added invoice'
  end

  # def invoice_parameters
  #   params.require(:invoice).permit!
  # end

  def load_invoice_from_template
    result = Procurements::Invoices::Templates::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.template
    self.invoice = self.template.resource.amoeba_dup
  end
end