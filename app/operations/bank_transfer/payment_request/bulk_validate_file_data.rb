class BankTransfer::PaymentRequest::BulkValidateFileData < BankTransfer::PaymentRequest::Base

  attr_accessor :order_details, :error_messages

  def init
    self.order_details = params[:order_details]

  end

  def validate

  end

  def process
    self.order_details.each do |item|
      bank_account_no = item[:bank_account_number] || item["bank_account_number"]
      ifsc = item[:ifsc] || item["ifsc"]
      name = item[:name] || item["name"]
      id = item[:account_id] || item["account_id"]
      owner_name = item[:owner_name]
      note = item[:note]&.to_s || item["note"]&.to_s

      if item&.dig(:invoice_attributes, :invoice_items_attributes).present?
        item[:invoice_items_attributes] = item[:invoice_attributes][:invoice_items_attributes]
      end

      tds_amount = item[:tds_amount].to_f
      discount = item[:discount]
      advance_amount = item[:advance_amount].to_f
      roundoff_amount = item[:roundoff_amount].to_f
      advance = item[:advance]
      freight = item[:freight]
      tds = item[:tds]
      tax = item[:tax]
      invoice_number = item[:invoice_number]
      invoice_date = item[:invoice_date]
      due_date = item[:due_date]
      inclusive_of_taxes = StringUtils.to_bool(item[:inclusive_of_taxes])
      category_id = item[:category_id]
      gst_type_id = item[:gst_type_id]
      cost_center_id = item[:cost_center_id]
      tds_slab_id = item[:tds_slab_id]


      # deciding tax based on whether invoice items were entered or not
      tax_amount = discount_amount = amount = sub_total = items_net_amount = 0
      if item[:invoice_items_attributes].present?
        item[:invoice_items_attributes].each do |line_item|
          tax_amount = line_item[:tax_amount].to_f
          discount_amount = line_item[:discount_amount].to_f
          amount = line_item[:amount].to_f
          if inclusive_of_taxes
            sub_total = amount - discount_amount
          else
            sub_total = amount - discount_amount + tax_amount
          end
          items_net_amount += sub_total
        end
        net_amount = items_net_amount.to_f - tds_amount.to_f - advance_amount.to_f + freight.to_f
      else
        tax_amount = item[:tax_amount].to_f
        discount_amount = item[:discount_amount].to_f
        amount = item[:original_amount].to_f
        if inclusive_of_taxes
          net_amount = amount.to_f - discount_amount.to_f - tds_amount.to_f - advance_amount.to_f + freight.to_f
        else
          net_amount = amount.to_f - discount_amount.to_f + tax_amount.to_f - tds_amount.to_f - advance_amount.to_f + freight.to_f
        end
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

      unless validate_rate tds, 1, amount
        self.valid = false
        self.error_messages << "Invalid TDS entered"
      end

      unless validate_rate discount, 1, amount
        self.valid = false
        self.error_messages << "Invalid discount entered"
      end

      unless validate_rate advance, 1, advance
        self.valid = false
        self.error_messages << "Invalid advance entered"
      end

      # adding the custom fields for the particular invoice, using a ghost invoice
      self.ghost_invoice = Invoice.new
      custom_fields = {custom_fields: item[:custom_fields]} || {}
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
      if item&.dig(:invoice_items_attributes).present?
        # i.e. if the line items are present, recalculate the net amount
        invoice_net_amount = 0

        item[:invoice_items_attributes]&.each do |invoice_item|
          item_amount = invoice_item[:amount].to_f
          item_discount = invoice_item[:discount].to_f
          item_tax = invoice_item[:tax].to_f
          item_gst_type = invoice_item[:gst_type_id]
          item_rate = invoice_item[:rate].to_f
          item_quantity = invoice_item[:quantity].to_f
          item_description = invoice_item[:description]
          item_category_id = invoice_item[:category_id]
          item_discount_amount = invoice_item[:discount_amount].to_f
          item_tax_amount = invoice_item[:tax_amount].to_f
          item_hsn_sac = invoice_item[:hsn_sac]

          unless validate_rate item_tax, 1
            self.error_messages << "Invoice item tax rate is invalid"
            self.valid = false
          end

          unless validate_rate item_discount, 1
            self.error_messages << "Invoice item discount rate is invalid"
            self.valid = false
          end

          if item_description.blank?
            self.error_messages << "Item description canonot be blank"
          end

          # insert custom fields here

          if inclusive_of_taxes
            total_amount = item_amount - item_discount_amount
          else
            total_amount = item_amount - item_discount_amount + item_tax_amount
          end

          invoice_items << {
              description: item_description,
              tax: item_tax,
              tax_amount: item_tax_amount,
              discount: item_discount,
              discount_amount: item_discount_amount,
              quantity: item_quantity,
              rate: item_rate,
              category_id: item_category_id,
              amount: item_amount,
              gst_type_id: item_gst_type,
              total_amount: total_amount,
              hsn_sac: item_hsn_sac,
              net_total: total_amount
          }

          items_net_total += total_amount
          item_tax_total += item_tax_amount
          item_discount_total += item_discount_amount
          item_amounts_total += item_amount

        end

        # accounting for TDS, Advance and Freight in light of the new amount
        invoice_net_amount = items_net_total.to_f - tds_amount.to_f - advance_amount.to_f + freight.to_f
        # assigning discount amount, and tax amount as the sum of the individual amounts
        discount_amount = item_discount_total
        tax_amount = item_tax_total
      end

      # adding processable amount irrespective of whether it's valid or not
      self.requested_amount += invoice_net_amount

      if self.valid
        self.processable_amount += invoice_net_amount
      end

      self.payment_order_valid = false unless self.valid

      self.processed_order << {bank_account_no: bank_account_no, ifsc: ifsc, name: name, original_amount: amount, note: note, id: id,
                               tax_amount: tax_amount, tax: tax, tds_amount: tds_amount, tds: tds, gst_type_id: gst_type_id, owner_name: owner_name,
                               discount_amount: discount_amount, discount: discount, inclusive_of_taxes: inclusive_of_taxes,
                               advance: advance, advance_amount: advance_amount, freight: freight, category_id: category_id,
                               cost_center_id: cost_center_id, tds_slab_id: tds_slab_id, total_amount: amount,
                               invoice_number: invoice_number, invoice_date: invoice_date, due_date: due_date, custom_fields: {invoice: self.ghost_invoice.custom_fields},
                               net_amount: invoice_net_amount, invoice_items: invoice_items, roundoff_amount: roundoff_amount, balance_due: balance_due,
                               item_taxes_total: item_tax_total, item_discounts_total: item_discount_total, items_net_total: items_net_total, item_amounts_total: item_amounts_total,
                               valid: self.valid, messages: self.error_messages}
    end
  end

end