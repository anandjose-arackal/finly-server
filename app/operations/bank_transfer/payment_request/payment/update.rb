class BankTransfer::PaymentRequest::Payment::Update < BankTransfer::PaymentRequest::Payment::Base

  attr_accessor :payment, :payment_request, :payment_params, :invoice_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance, :advance_amount, :payment_order, :payment_amount, :bp_params, :po_params,
                :incoming_tds_for_po

  def init
    super
    id = params[:payment_id] || params[:payment][:id]
    self.payment = self.payment_order.payments.find_by(id: id)
    self.payment_params = payment_attributes
    self.payment_amount = self.payment_params&.dig(:amount_attributes).present? ? self.payment_params&.dig(:amount_attributes, :value).to_f : self.payment.amount.value.round(2)

  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment not found"
    end
    # validate custom fields
    if payment&.invoice.present? && params[:custom_fields].present?
      set_fields = set_custom_fields(false)
      unless set_fields&.success?
        add_message :error, set_fields&.messages&.dig(:error)
        return
      end
      valid = CustomField::Validate.(self.payment.invoice)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
    end

    # validate that the amount is being passed # todo - uncomment it later
    # unless payment_params&.dig(:invoice_attributes, :original_amount_attributes, :value).present? || (self.payment.parent_type == 'PurchaseOrder')
    #   add_message :error, "Sub Total cannot be blank"
    #   return
    # end

    # if the amount is inclusive of taxes, the tax cannot be blank
    if StringUtils.to_bool(payment_params&.dig(:invoice_attributes, :inclusive_of_taxes))
      if payment_params&.dig(:invoice_attributes, :tax).blank? && payment_params&.dig(:invoice_attributes, :invoice_items_attributes).blank?
        add_message :error, "When sub total is inclusive of taxes, tax rate cannot be blank"
        return
      end
    end

    # case self.payment.parent_type
    # when 'Invoice'
    #   invoice = payment.parent
    #   invoice_amount = invoice.balance_due&.value.to_f
    #   previous_payments = payment.parent.payments.where.not(id: payment.id).all_except_failed.joins(:amount).sum(:value).round(2)
    #   if payment_amount.to_f + previous_payments.to_f > invoice_amount
    #     add_message :error, "Payable amount cannot be greater than balance due."
    #     return
    #   end
    # end
  end

  def pre_process

    # if self.payment.parent_type == "BeneficiaryPayment"
    #   construct_bp_params
    # end

    case self.payment.parent_type
    when 'BeneficiaryPayment'
      construct_bp_params
    when 'PurchaseOrder'
      construct_po_params
      validate_po_params
    end  

    # adding the invoice id so that it gets updated and not created again
    # if it already exists in the database
    if self.payment&.invoice.present? && self.payment_params[:invoice_attributes].present?
      self.payment_params[:invoice_attributes][:id] = self.payment.invoice.id
    end

    # adding id for original_amount and freight_amount so that new copies aren't created every time
    if payment_params&.dig(:invoice_attributes, :original_amount_attributes).present?
      payment_params[:invoice_attributes][:original_amount_attributes][:id] = self.payment&.invoice&.original_amount&.id
    end
    if payment_params&.dig(:invoice_attributes, :freight_amount_attributes).present?
      payment_params[:invoice_attributes][:freight_amount_attributes][:id] = self.payment&.invoice&.freight_amount&.id
    end

    if self.payment_params&.dig(:invoice_attributes, :invoice_attachments_attributes)
      # only if the actual attached file is present, do you even make it save
      if self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:attached_file].present?
        if self.payment&.invoice&.invoice_attachments.present?
          self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:id] = self.payment&.invoice.invoice_attachments.first&.id
        end
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first.delete(:remove_file)
      elsif self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:remove_file] == '1'
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:_destroy] = true
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first[:id] = self.payment&.invoice.invoice_attachments.first&.id
        self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first.delete(:remove_file)
      else
        if self.payment&.invoice&.invoice_attachments.present?
          self.payment_params[:invoice_attributes][:invoice_attachments_attributes].first.delete(:remove_file)
        else
          self.payment_params[:invoice_attributes].delete(:invoice_attachments_attributes)
        end
      end
    end

    # add logic to remove line items if required
    if self.payment_params&.dig(:invoice_attributes, :invoice_items_attributes).present?
      self.payment_params[:invoice_attributes][:invoice_items_attributes].each do |data|
        if StringUtils.to_bool(data[:remove_line_item])
          data[:_destroy] = true
          data.delete(:remove_line_item)
        else
          data.delete(:remove_line_item)
        end
      end
    end

    # # if nothing is passed inside invoice items attributes, assume that all are to be deleted
    # if self.payment_params&.dig(:invoice_attributes, :invoice_items_attributes).blank?
    #   if self.payment&.invoice&.invoice_items.present?
    #     self.payment_params[:invoice_attributes][:invoice_items_attributes] = []
    #     self.payment&.invoice&.invoice_items.each do |item|
    #       self.payment_params[:invoice_attributes][:invoice_items_attributes] << {
    #           id: item.id,
    #           _destroy: true
    #       }
    #     end
    #   end
    # end

    # if inclusive of taxes is not sent in the backend, mark it as false
    # if self.payment_params&.dig(:invoice_attributes)
    #   self.payment_params[:invoice_attributes][:inclusive_of_taxes] = !!self.payment_params[:invoice_attributes][:inclusive_of_taxes]
    # end

    if self.payment_params&.dig(:invoice_attributes, :category_id)
      self.payment_params[:category_id] = payment_params[:invoice_attributes][:category_id]
    end

    if payment.parent_type == 'PurchaseOrder'
      self.payment_params.delete(:invoice_attributes)
    end

    # if tax invoice po has advance amount, prevent modification of invoice tds slab
    if payment.parent_type == 'Invoice'
      procurement = payment.parent.procurement
      purchase_order = payment.parent.procurement.purchase_order
      if procurement.po_revisions.present?
        po_revision = procurement.po_revisions.last
        if po_revision.present?
          purchase_order = po_revision
        end
      end

      # remove this check permanently, causing customer issue with their internal process of tds deduction 
      #
      # if self.payment.parent.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice)
      #   if purchase_order.advance_tds_slab_id.present? && (self.payment_params.dig(:invoice_attributes, :tds_slab_id).to_i != self.payment.parent.tds_slab_id) && purchase_order.advance_amount_required
      #     add_message :error, "TDS slab selected for invoice has to match with the TDS slab for PO advance  - #{purchase_order.advance_tds_slab&.name}"
      #     return
      #   end
      # end
    end
  end

  def process

    payment.assign_attributes(payment_params)
    unless self.payment.valid?
      add_message :error, self.payment.errors.full_messages
      return
    end
    if payment.invoice&.present?
      calculate_tax_and_discounts
    end

    set_custom_fields(false) # this should hopefully add the attributes to the model
    ActiveRecord::Base.transaction(requires_new: true) do
      if self.payment.save
        recalculate_totals # this is because assign_attributes doesn't record the fact that one of the child items is marked for destruction
        validate_payable_amount
        if has_errors?
          raise ActiveRecord::Rollback
        end
      else
        add_message :error, self.payment.errors.full_messages
      end
    end

    case payment.parent_type
    when 'BeneficiaryPayment'
      bp = BeneficiaryPayment.find_by(id: payment.parent_id)
      self.bp_params[:original_amount_attributes][:id] = bp.original_amount_id
      self.bp_params[:advance_amount_attributes][:id] = bp.advance_amount_id
      bp.assign_attributes(self.bp_params)
      bp.calculate_tax_and_amount
      bp.save
    when 'PurchaseOrder'
      purchase_order = PurchaseOrder.find_by(id: payment.parent_id)
      # trigger the calculation only if tds sent and it is different from po tds
      # if self.payment_params[:invoice_attributes][:tds_slab_id].present? && (self.payment_params[:invoice_attributes][:tds_slab_id].to_i != purchase_order.advance_tds_slab_id)
      if self.incoming_tds_for_po != purchase_order.advance_tds_slab_id
        purchase_order.assign_attributes(self.po_params)
        purchase_order.save
        purchase_order.process_line_item_calculation
        purchase_order.save
      end
      # self.payment_params.delete(:invoice_attributes)
      # self.payment_params[:amount_attributes][:value] = purchase_order.advance_amount&.value

      payment.amount.update(value: purchase_order.advance_amount&.value)
    end

  end

  def post_process
    self.payment_order.update_requested_amount
    recheck_payable_flag
    add_message :success, "Payment updated"
  end

  private

  def payment_attributes
    params.require(:payment).permit(:note,
                                    invoice_attributes: [:tax, :gst_type_id, :tds, :tds_type_id, :category_id, :cost_center_id, :tds_slab_id,
                                                         :tax_type_id, :discount, :date, :discount_type_id, :due_date, :roundoff_amount,
                                                         :invoice_number, :inclusive_of_taxes, :advance, :advance_type_id,
                                                         # payment_notification_users: [:cc_emails],
                                                         original_amount_attributes: [:value, :currency_id],
                                                         freight_amount_attributes: [:value, :currency_id],
                                                         advance_amount_attributes: [:value, :currency_id],
                                                         invoice_attachments_attributes: [:attached_file, :description, :remove_file],
                                                         invoice_items_attributes: [:quantity, :rate, :tax, :discount, :category_id, :description, :id, :remove_line_item, :hsn_sac]],
                                    amount_attributes: [:value, :currency_id]
                                   )
  end

  def set_custom_fields(save)
    fields = params[:custom_fields]
    if fields.blank?
      return
    end
    custom_fields = {custom_fields: fields}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(self.payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

  def calculate_tax_and_discounts
    if self.payment.invoice.invoice_items.present?
      # if there are no invoice items, use the invoice library to calculate the amounts
      # 
      # check to make sure no other ticket type has an explicit payment amount, coming from FE, sent to utils
      case payment.parent_type
      when 'Invoice'
        InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, self.payment_amount)
      else
        InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil)
      end
    else
      # if there are, in fact, invoice items, use the invoice items library
      case payment.parent_type
      when 'Invoice'
        InvoiceCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, self.payment_amount)
        InvoiceCalculationUtils.new.calculate_cn_adjustments(self.payment_params, self.payment, nil)
      else
        InvoiceCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil)
      end
    end
    return
  end

  def recalculate_totals
    payable_amount = payment.amount_value
    if payment.invoice&.invoice_items.present?
      case payment.parent_type
      when 'Invoice'
        InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, payable_amount)
      else
        InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil)
      end
    else
      # if there are, in fact, invoice items, use the invoice items library
      case payment.parent_type
      when 'Invoice'
        InvoiceCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, payable_amount)
        InvoiceCalculationUtils.new.calculate_cn_adjustments(self.payment_params, self.payment, nil)
      else
        InvoiceCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil)
      end
    end
    self.payment.save
  end

  def construct_bp_params

    bp_payment = {}

    bp_payment[:gst_type_id] = self.payment_params[:invoice_attributes][:gst_type_id]
    bp_payment[:tds_slab_id] = self.payment_params[:invoice_attributes][:tds_slab_id]
    bp_payment[:inclusive_of_taxes] = self.payment_params[:invoice_attributes][:inclusive_of_taxes]
    bp_payment[:tax] = self.payment_params[:invoice_attributes][:tax]
    bp_payment[:original_amount_attributes] = self.payment_params[:invoice_attributes][:original_amount_attributes]
    bp_payment[:advance_amount_attributes] = self.payment_params[:invoice_attributes][:advance_amount_attributes]
    bp_payment[:roundoff_amount] = self.payment_params[:invoice_attributes][:roundoff_amount]
    bp_payment[:tax_rate_id] = params[:payment][:invoice_attributes][:tax_rate_id]
    params.require(:payment).permit!
    bp_payment[:payment_notification_users] = params.require(:payment).dig(:invoice_attributes, :payment_notification_users).to_h rescue nil
    self.bp_params = bp_payment

  end

  def construct_po_params
    po_payment = {}

    if self.payment_params[:invoice_attributes].present? && self.payment_params[:invoice_attributes][:tds_slab_id].present?
      po_payment[:advance_tds_slab_id] = self.payment_params[:invoice_attributes][:tds_slab_id]
    else
      po_payment[:advance_tds_slab_id] = nil
    end

    self.po_params = po_payment
  end

  def validate_po_params
    if self.payment_params[:invoice_attributes].present? && self.payment_params[:invoice_attributes][:tds_slab_id].present?
      self.incoming_tds_for_po = self.payment_params[:invoice_attributes][:tds_slab_id]
    else
      self.incoming_tds_for_po = self.payment_params[:invoice_attributes]
    end
  end

  def recheck_payable_flag
    case payment.parent_type
    when 'Invoice'
      invoice = payment.parent
      total_payments = invoice.payments.all_except_failed.joins(:amount).sum(:value).round(2)
      invoice_amount = invoice.balance_due&.value.to_f

      if total_payments + 0.99 < invoice_amount # add buffer for less than 1 rupee
        invoice.update payable: true
      else
        invoice.update payable: false
      end
    end
  end

  def validate_payable_amount
    case self.payment.parent_type
    when 'BeneficiaryPayment'
      if precision_value(payment.invoice.balance_due.value.to_f) < precision_value(payment.amount_value.to_f)
        add_message :error, "Payable amount cannot be greater than balance due"
        return
      end
    when 'Invoice'
      invoice = payment.parent
      invoice_amount = invoice.balance_due&.value.round(2)
      previous_payments = payment.parent.payments.where.not(id: payment.id).all_except_failed.joins(:amount).sum(:value).round(2)
      if payment_amount.to_f + previous_payments.to_f > (invoice_amount + 1) # this is to allow for any rounding issues that might occur during the updates of TDS
        add_message :error, "Payable amount cannot be greater than balance due."
        return
      end
    end
  end

end

