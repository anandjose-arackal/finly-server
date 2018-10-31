class BankTransfer::PaymentRequest::BulkProcessFromFile < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_order_data, :processed_order, :requested_amount, :processable_amount, :policy_id,
                :errors, :payment_order_valid, :scheduled_at, :description, :valid, :error_messages

  # the object that will hold the details of the custom fields because the object hasn't been created
  attr_accessor :ghost_invoice, :ghost_invoice_item

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def init
    self.payment_order_data = params[:payment_order]
    self.errors = []
    self.payment_order_valid = true # setting it true here for now, so that if it fails later that can be taken up
    self.requested_amount = 0
    self.processable_amount = 0
    self.processed_order = []
    self.scheduled_at = Date.parse params[:scheduled_at] if params[:scheduled_at].present? and DateUtils.validate_date_format?(params[:scheduled_at])
    self.description = params[:description]
    self.policy_id = params[:policy_id]

    if scheduled_at.present? and scheduled_at < Date.today
      self.scheduled_at = Date.today
    end

    od = []
    if payment_order_data.is_a?(Hash)
      payment_order_data.each do |key, value|
        od << value
      end
      self.payment_order_data = od
    end
  end

  def validate
    if payment_order_data.blank?
      self.errors << 'Error loading order details'
      return
    end

    if self.policy_id.blank?
      add_message :error, "Policy cannot be blank"
      return
    end

  end

  def process
    if payment_order_data.is_a?(Hash)
      arr = []
      self.payment_order_data.map {|k, v| arr << v }
      self.payment_order_data = arr
    end

    self.payment_order_data.each do |item|
      bank_account_no = item[:bank_account_number] || item["bank_account_number"]
      ifsc = item[:ifsc] || item["ifsc"]
      name = item[:name] || item["name"]
      owner_name = item[:owner_name]
      note = item[:note]&.to_s || item["note"]&.to_s

      tds_amount = item[:tds_amount].to_f
      discount = item[:discount]
      advance_amount = item[:advance_amount].to_f
      roundoff_amount = item[:roundoff_amount].to_f
      advance = item[:advance]
      freight = item[:freight]
      tds_slab_id = item[:tds_slab_id]
      tax = item[:tax]
      invoice_number = item[:invoice_number]
      invoice_date = item[:invoice_date]
      due_date = item[:due_date]
      inclusive_of_taxes = StringUtils.to_bool(item[:inclusive_of_taxes])
      category_id = item[:category_id]
      gst_type_id = item[:gst_type_id]
      cost_center_id = item[:cost_center_id]
      department_id = item[:department_id]
      tds_slab_id = item[:tds_slab_id]


      # deciding tax based on whether invoice items were entered or not
      tax_amount = item[:tax_amount].to_f
      discount_amount = item[:discount_amount].to_f
      amount = item[:original_amount].to_f
      if inclusive_of_taxes
        net_amount = amount.to_f - discount_amount.to_f - tds_amount.to_f - advance_amount.to_f + freight.to_f
      else
        net_amount = amount.to_f - discount_amount.to_f + tax_amount.to_f - tds_amount.to_f - advance_amount.to_f + freight.to_f
      end

      # calculate balance due with roundoff amount
      if roundoff_amount != 0
        balance_due = net_amount + roundoff_amount
      else
        balance_due = net_amount
      end

      self.valid = true
      self.error_messages = []


      # Check if bank account number is present
      if bank_account_no.blank?
        self.valid = false
        self.error_messages << 'Bank account not found'
      end

      # Check if the amount is present
      unless validate_amount(amount)
        self.valid = false
        self.error_messages << 'Invalid amount'
      end

      # check if the ifsc is present
      if ifsc.blank?
        self.valid = false
        self.error_messages << 'IFSC cannot be blank'
      end

      # check for format of the IFSC
      pattern = Regexp.new(Constants::VALID_IFSC)
      unless ifsc =~ pattern
        self.valid = false
        self.error_messages << "Invalid IFSC"
      end

      # adding all invoice specific validations here for the payment
      unless validate_date invoice_date
        self.valid = false
        self.error_messages << "Invalid invoice date"
      end

      unless validate_date due_date
        self.valid = false
        self.error_messages << "Invalid due date"
      end

      unless validate_rate tax, 1, amount
        self.valid = false
        self.error_messages << "Invalid tax entered"
      end

      unless validate_rate discount, 1, amount
        self.valid = false
        self.error_messages << "Invalid discount entered"
      end

      unless validate_rate advance, 1, advance
        self.valid = false
        self.error_messages << "Invalid advance entered"
      end
      custom_fields = {}
      # adding custom field values here for assigning to the invoice
      payment_order_custom_fields = current_company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
      payment_order_custom_fields.each_with_index do |field_config, index|
        case field_config.field_type_id
          when FieldType.id_for(:multiselect)
            custom_fields[field_config.id] = item[field_config.field_name.gsub(" ", "_").underscore].present? ? [item[field_config.field_name.gsub(" ", "_").underscore]] : []
          else
            custom_fields[field_config.id] = item[field_config.field_name.gsub(" ", "_").underscore]
        end
      end

      # adding the custom fields for the particular invoice, using a ghost invoice
      self.ghost_invoice = Invoice.new
      custom_fields = {custom_fields: custom_fields} || {}
      custom_fields[:user] = user
      custom_fields[:reset_fields] = true
      custom_fields[:save] = false
      CustomField::SetFields.(self.ghost_invoice, FieldParentType.id_for(:invoice), custom_fields)

      op = CustomField::Validate.(self.ghost_invoice)
      unless op.success?
        self.error_messages << op.messages[:error]
        self.valid = false
      end

      invoice_items = []

      invoice_net_amount = net_amount

      item_tax_total = item_discount_total = items_net_total = item_amounts_total = 0

      # adding processable amount irrespective of whether it's valid or not
      self.requested_amount += invoice_net_amount

      if self.valid
        self.processable_amount += invoice_net_amount
      end

      self.payment_order_valid = false unless self.valid

      self.processed_order << {bank_account_no: bank_account_no, ifsc: ifsc, name: name, original_amount: amount, note: note,
                               tax_amount: tax_amount, tax: tax, tds_amount: tds_amount, gst_type_id: gst_type_id, owner_name: owner_name,
                               discount_amount: discount_amount, discount: discount, inclusive_of_taxes: inclusive_of_taxes,
                               advance: advance, advance_amount: advance_amount, freight: freight, category_id: category_id,
                               cost_center_id: cost_center_id, department_id: department_id, tds_slab_id: tds_slab_id, total_amount: amount,
                               invoice_number: invoice_number, invoice_date: invoice_date, due_date: due_date, custom_fields: {invoice: self.ghost_invoice.custom_fields},
                               net_amount: invoice_net_amount, invoice_items: invoice_items, roundoff_amount: roundoff_amount, balance_due: balance_due,
                               item_taxes_total: item_tax_total, item_discounts_total: item_discount_total, items_net_total: items_net_total, item_amounts_total: item_amounts_total,
                               valid: self.valid, messages: self.error_messages}
    end
  end

  def success
    params[:payment_order_data] = self.payment_order_data
    params[:processed_order] = self.processed_order
    params[:requested_amount] = self.requested_amount
    params[:processable_amount] = self.processable_amount
    params[:errors] = self.errors
    params[:payment_order_valid] = self.payment_order_valid
    params[:scheduled_at] = self.scheduled_at
    params[:description] = self.description
    params[:policy_id] = self.policy_id
    BankTransfer::PaymentRequest::Process::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Process::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order_data, :processed_order, :requested_amount, :processable_amount, :errors,
                  :payment_order_valid, :scheduled_at, :description, :policy_id, :custom_fields_config

    def init
      self.payment_order_data = params[:payment_order_data]
      self.processed_order = params[:processed_order]
      self.requested_amount = params[:requested_amount]
      self.processable_amount = params[:processable_amount]
      self.errors = params[:errors]
      self.payment_order_valid = params[:payment_order_valid]
      self.scheduled_at = params[:scheduled_at]
      self.description = params[:description]
      self.policy_id = params[:policy_id]
    end

    def scheduled_at_formatted
      DateUtils.date_formatted self.scheduled_at
    end

    def created_at_formatted
      DateUtils.date_formatted Date.today
    end

  end

  private

  def validate_rate(rate, rate_type_id, amount = nil)
    if rate.blank?
      return true
    end
    case rate_type_id
      when 1, '1'
        if rate.to_f >= 100
          return false
        end
      when 2, '2'
        return true
      else
        # do nothing?
    end
    true
  end

  def validate_date(date)
    if date.blank?
      return true
    end
    date_obj = Date.parse(date) rescue nil
    if date_obj.blank?
      return false
    end
    true
  end

  def validate_amount(amount)
    if amount.blank? || !amount.to_f&.is_a?(Numeric) || amount.to_f < 0
      return false
    end
    true
  end

end
