class BankTransfer::InwardInvoices::Update < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice, :inward_invoice_params, :custom_fields, :invoice_old_attachments, :invoice_current_attachments, :document_reviewer_mappings_params, :po_revision, :purchase_order, :procurement,
                :gstin_location, :cost_allocation_items, :policy


  def personalizer
    {
        post_process: {
            after: Personalizer::Process.new([:procurements, :invoices, :update], :post_process, self)
        }
    }
  end

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.scope_all_except_voided.find_by(id: id)
    self.inward_invoice_params = invoice_attributes
    self.custom_fields = params&.dig(:custom_fields) || params&.dig(:invoice, :custom_fields)

    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
      return
    end


    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]

    if self.inward_invoice.procurement.present?
      self.procurement = self.inward_invoice.procurement

      self.purchase_order = self.procurement.purchase_order

      if self.purchase_order.present?      
        self.gstin_location = self.purchase_order.gstin_location
      else
        self.gstin_location = self.inward_invoice&.vendor&.gstin_locations.find_by(id: inward_invoice_params[:gstin_location_id]) || self.inward_invoice.vendor&.gstin_locations&.first
      end

      # if self.procurement.po_revisions.present?
      #   self.po_revision = self.procurement.po_revisions.last
      #   if po_revision.present?
      #     self.purchase_order = self.po_revision
      #   end
      # end
    end

    # Check if department and cost center are to be saved globally for the non-po invoice or individually for each item
    self.cost_allocation_items = StringUtils.to_bool(self.inward_invoice_params[:cost_allocation_items])
    # self.inward_invoice_params.delete(:cost_allocation_items)

    self.policy = Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: self.inward_invoice_params[:policy_id])

    fetch_budget_contributions(inward_invoice)
  end

  def validate

    if self.inward_invoice_params[:invoice_number].blank?
      add_message :error, "Invoice number is required. You can input alphanumeric characters, dash and forward slash. No spaces allowed."
      return
    end

    if self.policy.blank? && self.inward_invoice.policy_id.blank?
      add_message :error, "Policy cannot be blank"
      return
    end

    
    # checking for duplicates within this particular company
    current_company_invoices = current_company.inward_invoices.scope_all_except_voided_rejected_retracted
    invoice_number = self.inward_invoice_params[:invoice_number]
    vendor_id = self.inward_invoice.vendor_id || params[:vendor_id]
    duplicate_invoices = current_company_invoices.with_invoice_number(invoice_number).with_vendor_ids(vendor_id).without_id(self.inward_invoice.id)
    if invoice_number.present? && duplicate_invoices.present?
      # add_message :error, "This invoice seems like a duplicate: Check invoice numbers: #{duplicate_invoices.pluck(:invoice_number).to_sentence}"
      add_message :error, "There is a similar invoice added with the same invoice number in our records. Please re-check your invoice details."
      return
    end

    if self.inward_invoice_params[:location_id].blank?
      add_message :error, "Please specify a Billing Address."
    end

    if self.inward_invoice_params[:delivery_location_id].blank?
      add_message :error, "Please specify a Shipping Address."
      return
    end

    if self.purchase_order&.advance_payments.blank? && StringUtils.to_bool(params[:invoice][:advance_amount_required])
      params[:invoice][:advance_amount_required] = false
    end

    if StringUtils.to_bool(params[:invoice][:advance_amount_required])
      self.inward_invoice_params[:advance_amount_required] = true
      if self.inward_invoice_params[:po_adjusted_advance_attributes][:value].blank?
        add_message :error, "Please add the advance amount to be adjusted for this Invoice."
        return
      end
      possible_adjustment = (self.inward_invoice.po_advance - self.inward_invoice.po_prev_adjusted_advance) rescue 0
      if self.inward_invoice_params[:po_adjusted_advance_attributes][:value].to_i > possible_adjustment
        add_message :error, "Error: Adjusted advance entered is more than the required Purchase Order advance.\n Maximum adjustment for this Invoice can be - \"#{possible_adjustment}\""
        return
      end
    else
      if self.inward_invoice_params[:advance_amount_required].present?
        self.inward_invoice_params[:advance_amount_required] = false
        self.inward_invoice_params[:po_adjusted_advance_attributes][:value] = 0
      end
    end

    if self.inward_invoice.procurement.present? && self.purchase_order.present?
      # if params[:invoice][:balance_amount_attributes][:value].to_i < 0
      #   add_message :error, "Balance due amount cannot be less than zero"
      # end
      if params[:invoice][:balance_amount_attributes][:value].to_i > (self.purchase_order.balance_amount&.value + 1) # adding a buffer to account for roundoff amount
          add_message :error, "Payable amount for this invoice has exceeded the Purchase Order payable amount."
        return
      end

      # the below line is in the case of one PO having multiple line items of the same inventory item
      processed_item_ids = []
      self.inward_invoice_params[:invoice_items_attributes].each do |item|
        po_item = self.purchase_order.items.without_id(processed_item_ids).find_by(id: item[:purchase_order_item_id])
        next if po_item.blank? # temp workaround
        item_q = (po_item&.inventory_line_item&.product_type_id == ProductType.id_for(:goods)) ? po_item.accepted : po_item.quantity

        unless user.company.feature_subscription.grn_enabled
          item_q = po_item.quantity
        end

        if item_q < item[:quantity].to_i
          add_message :error, "Invoice item quantity should be on par with the Purchase Order quantity."
          break
        end
        processed_item_ids << po_item.id
      end
    end

    if self.inward_invoice_params[:transaction_service_period_from].present?
      # split_date = self.inward_invoice_params[:transaction_service_period_from].split("/") # frontend sends in the format, mm/yyyy
      # formatted_month = split_date.first
      # formatted_year = split_date.last
      # unless is_valid_year?(formatted_year) && is_valid_month?(formatted_month)
      #   add_message :error, "Invalid Date."
      #   return
      # end
      # self.inward_invoice_params[:transaction_service_period_from] = Date.new(formatted_year.to_i, formatted_month.to_i)


      date = self.inward_invoice_params[:transaction_service_period_from]
      valid_date = Date.parse(date) rescue false

      unless valid_date
        add_message :error, "Invalid Date."
        return
      end

    end

    # To be introduced later
    if self.inward_invoice_params[:transaction_service_period_to].present?
      # split_date = self.inward_invoice_params[:transaction_service_period_to].split("/")
      # formatted_month = split_date.first
      # formatted_year = split_date.last
      # unless is_valid_year?(formatted_year) && is_valid_month?(formatted_month)
      #   add_message :error, "Invalid Date."
      #   return
      # end
      # self.inward_invoice_params[:transaction_service_period_to] = Date.new(formatted_year.to_i, formatted_month.to_i)

      date = self.inward_invoice_params[:transaction_service_period_to]
      valid_date = Date.parse(date) rescue false

      unless valid_date
        add_message :error, "Invalid Date."
        return
      end

    end

    # arr = self.inward_invoice_params[:invoice_items_attributes].pluck(:unit_of_measurement)

    # if arr.collect {|a| a.blank?}.include? true
    #   add_message :error, "Please mention the Unit of Measurement for the items supplied."
    #   return
    # end

    # Removing hard check for department and cc line item wise
    # if self.inward_invoice.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
    #   if self.cost_allocation_items
    #     arr = self.inward_invoice_params[:invoice_items_attributes].pluck(:department_id)

    #     if arr.collect {|a| a.blank? }.include? true
    #       add_message :error, "Please select a Department for which the item would be purchased."
    #       return
    #     end

    #     arr = self.inward_invoice_params[:invoice_items_attributes].pluck(:cost_center_id)

    #     if arr.collect {|a| a.blank? }.include? true
    #       add_message :error, "Please select a Cost Center for which the item would be purchased."
    #       return
    #     end
    #   else
    #     self.inward_invoice_params[:invoice_items_attributes].each do |item|
    #       item[:department_id] = self.inward_invoice_params[:department_id]
    #       item[:cost_center_id] = self.inward_invoice_params[:cost_center_id]
    #     end
    #   end
    # end

    unless self.cost_allocation_items
      self.inward_invoice_params[:invoice_items_attributes].each do |item|
        item[:department_id] = self.inward_invoice_params[:department_id]
        item[:cost_center_id] = self.inward_invoice_params[:cost_center_id]
      end
    end

    if self.inward_invoice_params[:bank_account_id].blank?
      add_message :error, "Please select the bank account for the vendor. If they are not present, please update this detail from the Vendor Empanelment screen."
      return
    end

    # Credit Note Adjustments Validation
    if inward_invoice_params[:credit_note_adjusments_attributes].present?
      inward_invoice_params[:credit_note_adjusments_attributes].each do |adjustment_attr|
        op = Docs::P2P::CreditNotes::Ops::Show(params: {id: adjustment_attr[:credit_note_id]}, current_user: user)
        unless op.success?
          add_message :error, "Credit Note not found for provided amount #{adjustment_attr[:amount][:value]}"
          next
        end

        credit_note = op['model']
        unless credit_note.vendor_id == invoice.vendor_id
          add_message :error, "Applied Credit Note #{credit_note.credit_note_number} doesn't belong to Vendor #{invoice.vendor.vendor_id}"
        end

        if adjustment_attr[:amount][:value].to_f > credit_note.net_adjustable_amount&.value.to_f
          add_message :error, "Cannot adjust amount more than available credits in Credit Note #{credit_note.credit_note_number} "
        end
      end
    end

    if self.inward_invoice_params[:date].blank?
      add_message :error, "Invoice date is mandatory"
      return
    end

    # Credit Note Check
    if self.inward_invoice_params[:credit_note_adjustments_attributes].present?
      self.inward_invoice_params[:credit_note_adjustments_attributes].filter {|cna| cna[:id].blank?}.each do |cna|
        cn = CreditNote.find_by id: cna[:credit_note_id]

        unless cn.present? || (cn.company_id == inward_invoice.company_id)
          add_message :error, "Credit Note Not Found"
          next
        end

        unless cn.approved? || cn.auto_approved? || cn.partially_adjusted? || cn.unadjusted?
          add_message :error, "Applied Credit Note with ID #{cn.sequence_id} is not in applicable at this state"
          next
        end

        if precision_value(cna[:amount_attributes][:value]) > precision_value(cn.net_adjustable_amount.value)
          add_message :error, "Applied Credit Note with ID #{cn.sequence_id}  doesn't have enough credits"
          next
        end
        # cna[:amount_attributes][:value] = precision_value(cna[:amount_attributes][:value])
      end
    end

    if self.inward_invoice.voided?
      add_message :error, "Invoice status is \"Void\". No further actions can be taken."
      return
    end
  end

  def pre_process
    # update gstin location id
    if inward_invoice_params[:gst_type_id].blank?
      if self.gstin_location.present?
        self.inward_invoice_params[:gstin_location_id] = self.gstin_location&.id

        shipping_location = user.company.locations.find_by(id: params[:shipping_location_id])
        if self.gstin_location.state_code == shipping_location&.state_code
          self.inward_invoice_params[:gst_type_id] = GstType.id_for(:cgst_sgst)
        else
          self.inward_invoice_params[:gst_type_id] = GstType.id_for(:igst)
        end
      else
        self.inward_invoice_params[:gst_type_id] = GstType.id_for(:igst)
      end
    end
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

    #strip_invoice_number
    if self.inward_invoice_params&.dig(:invoice_number).present?
      self.inward_invoice_params[:invoice_number] =self.inward_invoice_params[:invoice_number]&.strip
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

    receiving_account = self.inward_invoice.vendor&.bank_accounts&.find_by(id: self.inward_invoice_params[:bank_account_id])
    self.inward_invoice.receiving_account = receiving_account

    # remove this check permanently, causing customer issue with their internal process of tds deduction
    #
    # if self.inward_invoice.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice)
    #   if self.purchase_order.advance_tds_slab_id.present? && (inward_invoice_params[:tds_slab_id] != self.purchase_order.advance_tds_slab_id) && self.purchase_order.advance_amount_required
    #     add_message :error, "TDS slab selected for invoice has to match with the TDS slab for PO advance  - #{self.purchase_order.advance_tds_slab&.name}"
    #     return
    #   end
    # end

    # if self.inward_invoice_params[:credit_note_adjusments_attributes].present?
    #   self.inward_invoice_params[:credit_note_adjusments_attributes].each do |cna|
    #     cna[:amount_attributes][:value] = precision_value(cna[:amount_attributes][:value])
    #   end
    # end

  end

  def process
    ActiveRecord::Base.transaction(requires_new: true) do
      self.inward_invoice.assign_attributes(self.inward_invoice_params)
      calculate_tax_and_discounts(self.inward_invoice, self.inward_invoice_params)


      # Calculate the new balance_due based on credit notes
      # calculate_cn_adjustment


      # fail

      validate_custom_fields_invoice
      return if has_errors?

      if inward_invoice.valid?
        if Invoice.status_ids(:open, :retracted, :rejected).include?(inward_invoice.invoice_status_id) && inward_invoice.created_by_user_id == user.id

          params[:reviewal_document] = self.inward_invoice
          params[:document_reviewer_mappings] = document_reviewer_mappings_params
          params[:provider_name] = self.inward_invoice.get_invoice_provider_name
          document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
          unless document_reviewer_mappings_op.success?
            add_message :error, document_reviewer_mappings_op.messages[:error]
            return
          end
        end
      end

      # # Validate Credit Notes After Balance Due has been calculated
      # return unless validate_credit_notes

      if self.inward_invoice.save
        recalculate_totals(self.inward_invoice, self.inward_invoice_params)


        # calculate_cn_adjustment
        inward_invoice.save

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
        return
      end

      return if has_errors?

      # Budget check
      budget_validation_op = budget_limit_validation(inward_invoice)
      if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
        add_message :error, budget_validation_op.messages[:errors]
        raise ActiveRecord::Rollback
        return
      end
    end
  end

  def post_process
    # update_agreement_available_limit
    add_message :success, "Invoice updated"
  end

  private

  def is_valid_year? year
    return false if year.to_i.to_s != year #invalidate characters
    year.strip.to_i.between?(1900, Date.today.year)
  end

  def is_valid_month? month
    # return false if month.to_i.to_s != month #invalidate characters
    return false unless Date.strptime(month, "%m").gregorian? rescue false
    month.strip.to_i.between?(1, 12)
  end

  def validate_agreement_limit
    if self.inward_invoice.agreement_item.present? && self.inward_invoice.agreement_item_type == 'GeneralInvoice'
      payment_agreement = inward_invoice.agreement_item.payment_agreement
      if inward_invoice.agreement_item.total_invoice_amount&.value.present? && inward_invoice.agreement_item.billing_type.variable_periodic?
        available_limit = inward_invoice.agreement_item.total_invoice_amount&.value - get_invoice_amount_sum(payment_agreement)
        if available_limit.present? && available_limit < inward_invoice&.balance_due&.value
          add_message :error, "Balance due cannot exceed available agreement limit of Rs. #{available_limit}"
          return
        end
      end
    end
  end

  def validate_credit_notes
    credit_notes = inward_invoice.credit_note_adjustments
    return true if credit_notes.blank?

    balance_due = inward_invoice.balance_due.value

    adjusted_cn_total = credit_notes.map(&:amount).map(&:value).sum

    if precision_value(adjusted_cn_total) > precision_value(balance_due)
      add_message :error, "Total Credit Note Adjustment Amount Cannot Exceed Invoice Balance Due"
      return
    end
    true
  end

  def update_agreement_available_limit
    if self.inward_invoice.agreement_item.present? && self.inward_invoice.agreement_item.billing_type.variable_periodic?
      payment_agreement = self.inward_invoice.agreement_item.payment_agreement
      invoiced_amount_sum = get_invoice_amount_sum(payment_agreement)
      available_limit = self.inward_invoice.agreement_item.total_invoice_amount&.value - invoiced_amount_sum
      self.inward_invoice.agreement_item.available_invoice_amount.update(value: available_limit, currency_id: 1)
      return
    end
  end

  # For invoices created from variable periodic agreement based payments
  def get_invoice_amount_sum(payment_agreement)
    payment_agreement.agreement_invoices.where(agreement_item_id: self.inward_invoice.agreement_item_id).collect{|i| i.balance_due.value}.sum
  end

  def calculate_cn_adjustment
    return if inward_invoice.blank?
    InvoiceCalculationUtils.new.calculate_cn_adjustments(inward_invoice_params, nil, inward_invoice)
  end
end
