class BankTransfer::PaymentRequest::Payment::Update < BankTransfer::PaymentRequest::Payment::Base

  attr_accessor :payment, :payment_request, :payment_params, :invoice_amount, :payment_amount,
                :gross_amount, :net_amount, :invoice,
                :discount_amount, :tds_amount, :tax_amount, :original_amount, :after_tax_amount,
                :advance, :advance_amount, :payment_order, :payment_amount

  def init
    super
    id = params[:payment_id] || params[:payment][:id]
    self.payment = self.payment_order.payments.find_by(id: id)
    self.payment_params = payment_attributes
    self.payment_amount = self.payment_params&.dig(:amount_attributes, :value).to_f
  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment not found"
    end
    # validate custom fields
    if payment&.invoice.present?
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
    unless payment_params&.dig(:invoice_attributes, :original_amount_attributes, :value).present?
      add_message :error, "Sub Total cannot be blank"
      return
    end

    # if the amount is inclusive of taxes, the tax cannot be blank
    if StringUtils.to_bool(payment_params&.dig(:invoice_attributes, :inclusive_of_taxes))
      if payment_params&.dig(:invoice_attributes, :tax).blank? && payment_params&.dig(:invoice_attributes, :invoice_items_attributes).blank?
        add_message :error, "When sub total is inclusive of taxes, tax rate cannot be blank"
        return
      end
    end
  end

  def pre_process
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

    # if nothing is passed inside invoice items attributes, assume that all are to be deleted
    if self.payment_params&.dig(:invoice_attributes, :invoice_items_attributes).blank?
      if self.payment&.invoice&.invoice_items.present?
        self.payment_params[:invoice_attributes][:invoice_items_attributes] = []
        self.payment&.invoice&.invoice_items.each do |item|
          self.payment_params[:invoice_attributes][:invoice_items_attributes] << {
              id: item.id,
              _destroy: true
          }
        end
      end
    end

    # if inclusive of taxes is not sent in the backend, mark it as false
    if self.payment_params&.dig(:invoice_attributes)
      self.payment_params[:invoice_attributes][:inclusive_of_taxes] = !!self.payment_params[:invoice_attributes][:inclusive_of_taxes]
    end

    if self.payment_params&.dig(:invoice_attributes, :category_id)
      self.payment_params[:category_id] = payment_params[:invoice_attributes][:category_id]
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
    if self.payment.save
      recalculate_totals # this is because assign_attributes doesn't record the fact that one of the child items is marked for destruction
    else
      add_message :error, self.payment.errors.full_messages
    end
  end

  def post_process
    self.payment_order.update_requested_amount
    add_message :success, "Payment updated"
  end

  private

  def payment_attributes
    params.require(:payment).permit(:note,
                                    invoice_attributes: [:tax, :gst_type_id, :tds, :tds_type_id, :category_id, :cost_center_id, :tds_slab_id,
                                                         :tax_type_id, :discount, :date, :discount_type_id, :due_date, :roundoff_amount,
                                                         :invoice_number, :inclusive_of_taxes, :advance, :advance_type_id,
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
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, self.payment_amount)
    else
      # if there are, in fact, invoice items, use the invoice items library
      InvoiceCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, self.payment_amount)
    end
    return
  end

  def recalculate_totals
    if payment.invoice.invoice_items.present?
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, self.payment_amount)
    else
      # if there are, in fact, invoice items, use the invoice items library
      InvoiceCalculationUtils.new.calculate_tax_and_discounts(self.payment_params, self.payment, nil, self.payment_amount)
    end
    self.payment.save
  end

end