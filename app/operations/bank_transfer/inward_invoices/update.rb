class BankTransfer::InwardInvoices::Update < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice, :inward_invoice_params, :custom_fields, :invoice_old_attachments, :invoice_current_attachments, :document_reviewer_mappings_params

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
    self.inward_invoice_params = invoice_attributes
    self.custom_fields = params&.dig(:invoice, :custom_fields)
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]
  end

  def validate
    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    # checking for duplicates within this particular company
    current_company_invoices = current_company.inward_invoices
    invoice_number = self.inward_invoice_params[:invoice_number]
    vendor_id = self.inward_invoice.vendor_id || params[:vendor_id]
    duplicate_invoices = current_company_invoices.with_invoice_number(invoice_number).with_vendor_ids(vendor_id).without_id(self.inward_invoice.id)
    if invoice_number.present? && duplicate_invoices.present?
      add_message :error, "This invoice seems like a duplicate: Check invoice numbers: #{duplicate_invoices.pluck(:invoice_number).to_sentence}"
      return
    end

    if params[:advance_amount_required]
      if self.inward_invoice_params[:po_adjusted_advance_attributes][:value].blank?
        add_message :error, "Please add the advance amount to be adjusted for this Invoice."
        return
      end
      if self.inward_invoice_params[:po_adjusted_advance_attributes][:value].to_i > self.inward_invoice.po_advance
        add_message :error, "Error: Adjusted advance entered is more than the required Purchase Order advance."
        return
      end
    end
  end

  def pre_process
    # adding id for original_amount and freight_amount so that new copies aren't created every time
    if inward_invoice_params&.dig(:original_amount_attributes).present?
      inward_invoice_params[:original_amount_attributes][:id] = self.inward_invoice&.original_amount&.id
    end
    if inward_invoice_params&.dig(:freight_amount_attributes).present?
      inward_invoice_params[:freight_amount_attributes][:id] = self.inward_invoice&.freight_amount&.id
    end
    if inward_invoice_params&.dig(:advance_amount_attributes).present?
      inward_invoice_params[:advance_amount_attributes][:id] = self.inward_invoice&.advance_amount&.id
    end

    # setting the inclusive of taxes explicitly here because if unchecked it doesn't send anything from the frontend
    if self.inward_invoice_params[:inclusive_of_taxes].blank?
      self.inward_invoice_params[:inclusive_of_taxes] = false
    end

    if self.inward_invoice_params&.dig(:invoice_attachments_attributes)
      # only if the actual attached file is present, do you even make it save
      if self.inward_invoice_params[:invoice_attachments_attributes].first[:attached_file].present?
        if self.inward_invoice&.invoice_attachments.present?
          self.inward_invoice_params[:invoice_attachments_attributes].first[:id] = self.inward_invoice.invoice_attachments.first&.id
        end
        self.inward_invoice_params[:invoice_attachments_attributes].first.delete(:remove_file)
      elsif self.inward_invoice_params[:invoice_attachments_attributes].first[:remove_file] == '1'
        self.inward_invoice_params[:invoice_attachments_attributes].first[:_destroy] = true
        self.inward_invoice_params[:invoice_attachments_attributes].first[:id] = self.inward_invoice.invoice_attachments.first&.id
        self.inward_invoice_params[:invoice_attachments_attributes].first.delete(:remove_file)
      else
        if self.inward_invoice&.invoice_attachments.present?
          self.inward_invoice_params[:invoice_attachments_attributes].first.delete(:remove_file)
        else
          self.inward_invoice_params.delete(:invoice_attachments_attributes)
        end
      end
    end

    # Procurement Attachments
    self.invoice_current_attachments = user.company.procurement_attachments.with_id(inward_invoice_params[:attachments])
    self.inward_invoice_params.delete(:attachments)
    self.invoice_old_attachments = self.inward_invoice.attachments

    # add logic to remove line items if required
    if inward_invoice_params&.dig(:invoice_items_attributes).present?
      self.inward_invoice_params[:invoice_items_attributes].each do |data|
        if StringUtils.to_bool(data[:remove_line_item])
          data[:_destroy] = true
          data.delete(:remove_line_item)
        else
          data.delete(:remove_line_item)
        end
      end
    end

    # if nothing is passed inside invoice items attributes, assume that all are to be deleted
    if self.inward_invoice_params&.dig(:invoice_items_attributes).blank?
      if self.inward_invoice&.invoice_items.present?
        self.inward_invoice_params[:invoice_items_attributes] = []
        self.inward_invoice&.invoice_items.each do |item|
          self.inward_invoice_params[:invoice_items_attributes] << {
              id: item.id,
              _destroy: true
          }
        end
      end
    end

    # if the vendor receiving account is not set here, set it explicitly as bank account
    if self.inward_invoice.receiving_account_type.blank?
      self.inward_invoice_params[:receiving_account_type] = BankAccount.name
    end
  end

  def process
    self.inward_invoice.assign_attributes(self.inward_invoice_params)
    calculate_tax_and_discounts(self.inward_invoice, self.inward_invoice_params)

    validate_custom_fields_invoice
    return if has_errors?

    if inward_invoice.valid?
      if Invoice.status_ids(:open, :retracted, :rejected).include?(inward_invoice.invoice_status_id) && inward_invoice.created_by_user_id == user.id

        params[:reviewal_document] = self.inward_invoice
        params[:document_reviewer_mappings] = document_reviewer_mappings_params

        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        unless document_reviewer_mappings_op.success?
          add_message :error, document_reviewer_mappings_op.messages[:error]
          return
        end
      end
    end

    if self.inward_invoice.save
      recalculate_totals(self.inward_invoice, self.inward_invoice_params)

      self.invoice_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)
      self.invoice_current_attachments.update_all(procurement_document_id: inward_invoice.id, procurement_document_type: inward_invoice.class.name)

      # Create trail for procurement
      if self.inward_invoice.procurement_id.present?
        unless inward_invoice.created_by == user
          inward_invoice.trails.create action_user: user,
                                action_id: TrailAction.id_for(:update),
                                action_level: inward_invoice.trails.last.action_level
        end
      end
    else
      add_message :error, self.inward_invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice updated"

  end

end
