class BankTransfer::InwardInvoices::Update < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice, :inward_invoice_params, :custom_fields, :invoice_old_attachments, :invoice_current_attachments, :document_reviewer_mappings_params, :po_revision, :purchase_order, :procurement,
                :gstin_location

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
    self.inward_invoice_params = invoice_attributes
    self.custom_fields = params&.dig(:invoice, :custom_fields)


    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]

    if self.inward_invoice.procurement.present?
      self.procurement = self.inward_invoice.procurement

      self.purchase_order = self.procurement.purchase_order

      if self.purchase_order.present?      
        self.gstin_location = self.purchase_order.gstin_location
      else
        self.gstin_location = self.inward_invoice&.vendor&.gstin_locations.find_by(id: inward_invoice_params[:gstin_location_id]) || self.inward_invoice.vendor&.gstin_locations&.first
      end

      if self.procurement.po_revisions.present?
        self.po_revision = self.procurement.po_revisions.last
        if po_revision.present?
          self.purchase_order = self.po_revision
        end
      end
    end


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
      # add_message :error, "This invoice seems like a duplicate: Check invoice numbers: #{duplicate_invoices.pluck(:invoice_number).to_sentence}"
      add_message :error, "There is a similar invoice added with the same invoice number in our records. Please re-check your invoice details."
      return
    end

    if StringUtils.to_bool(params[:invoice][:advance_amount_required])
      self.inward_invoice_params[:advance_amount_required] = true
      if self.inward_invoice_params[:po_adjusted_advance_attributes][:value].blank?
        add_message :error, "Please add the advance amount to be adjusted for this Invoice."
        return
      end
      if self.inward_invoice_params[:po_adjusted_advance_attributes][:value].to_i > self.inward_invoice.po_advance
        add_message :error, "Error: Adjusted advance entered is more than the required Purchase Order advance."
        return
      end
    else
      if self.inward_invoice_params[:advance_amount_required].present?
        self.inward_invoice_params[:advance_amount_required] = false
        self.inward_invoice_params[:po_adjusted_advance_attributes][:value] = self.inward_invoice&.po_adjusted_advance&.value || 0
      end
    end

    if self.inward_invoice.procurement.present? && self.purchase_order.present?
        if params[:invoice][:balance_amount_attributes][:value].to_i > self.purchase_order.balance_amount&.value
            add_message :error, "Payable amount for this invoice has exceeded the Purchase Order payable amount."
          return
        end 

        self.inward_invoice_params[:invoice_items_attributes].each do |item|
          po_item = self.purchase_order.items.find_by(inventory_line_item_id: item[:inventory_line_item_id])

          item_q = (po_item&.inventory_line_item&.product_type_id == ProductType.id_for(:goods)) ? po_item.accepted : po_item.quantity

          if item_q < item[:quantity].to_i
            add_message :error, "Invoice item quantity should be on par with the Purchase Order quantity."
            break
          end
        end
    end

    if self.inward_invoice_params[:billing_cycle_from].present?
      split_date = self.inward_invoice_params[:billing_cycle_from].split("-") # frontend sends in the format, 00-mm-yyyy
      formatted_month = split_date[1]
      formatted_year = split_date.last

      unless is_valid_year?(formatted_year) && is_valid_month?(formatted_month)
        add_message :error, "Invalid Date."
        return
      end
      self.inward_invoice_params[:billing_cycle_from] = Date.new(formatted_year.to_i, formatted_month.to_i)
    end

    if self.inward_invoice_params[:billing_cycle_to].present?
      split_date = self.inward_invoice_params[:billing_cycle_to].split("-")
      formatted_month = split_date[1]
      formatted_year = split_date.last
      unless is_valid_year?(formatted_year) && is_valid_month?(formatted_month)
        add_message :error, "Invalid Date."
        return
      end
      self.inward_invoice_params[:billing_cycle_to] = Date.new(formatted_year.to_i, formatted_month.to_i)
    end


  end

  def pre_process
    # update gstin location id
    if self.gstin_location.present?
      self.inward_invoice_params[:gstin_location_id] = self.gstin_location&.id
    end


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

  private

  def is_valid_year? year
    return false if year.to_i.to_s != year #invalidate characters
    year.strip.to_i.between?(1900, Date.today.year)
  end

  def is_valid_month? month
    return false if month.to_i.to_s != month #invalidate characters
    month.strip.to_i.between?(1, 12)
  end


end
