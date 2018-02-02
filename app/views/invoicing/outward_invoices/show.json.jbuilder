invoice = @result.invoice
if invoice.present?
  json.summary do
    json.order_status do
      json.name invoice.invoice_status&.name
      json.identifier invoice.invoice_status_identifier
    end
    json.invoice_number invoice.invoice_number
    json.date invoice.date
    json.due_date invoice.due_date

    json.payment_term_name invoice.payment_term&.name
    json.payment_term_id invoice.payment_term&.id

    json.policy do
      json.id invoice.policy_id
      json.name invoice.policy&.name
    end

    json.status do
      json.name invoice.invoice_status&.name&.humanize
    end

    json.virtual_account do
      json.id invoice.virtual_bank_account&.id
      json.account_number invoice.virtual_bank_account&.account_number
      json.ifsc invoice.virtual_bank_account&.ifsc
      json.name invoice.virtual_bank_account&.name
    end

    json.shipping_address do
      json.line_1 invoice.shipping_address&.line_1
      json.line_2 invoice.shipping_address&.line_2
      json.line_3 invoice.shipping_address&.line_3
      json.name invoice.shipping_address&.name
      json.state_id invoice.shipping_address&.state_id
      json.name invoice.shipping_address&.name
      json.pin_code invoice.shipping_address&.pin_code
      json.city invoice.shipping_address&.city
      json.state_name invoice.shipping_address&.state&.name
    end

    json.billing_address do
      # billing address details
      json.line_1 invoice.billing_address&.line_1
      json.line_2 invoice.billing_address&.line_2
      json.line_3 invoice.billing_address&.line_3
      json.name invoice.billing_address&.name
      json.state_id invoice.billing_address&.state_id
      json.name invoice.billing_address&.name
      json.pin_code invoice.billing_address&.pin_code
      json.city invoice.billing_address&.city
      json.state_name invoice.billing_address&.state&.name
    end
  end

  if invoice.customer.present?
    json.customer do
      json.name invoice.customer&.name
      json.id invoice.customer&.id
      json.mobile_number invoice.customer&.mobile_number
      json.email invoice.customer&.email
    end
  end

  json.invoice do
    json.total_amount precision_value invoice.amount&.value
    json.advance precision_value invoice.advance
    json.advance_amount precision_value invoice.advance_amount&.value
    json.gst_type_id invoice.gst_type_id
    json.freight_amount precision_value invoice.freight_amount&.value
    json.roundoff_amount precision_value invoice.roundoff_amount&.value
    json.balance_due precision_value invoice.balance_due&.value
    json.net_amount precision_value invoice.net_amount&.value
    json.inclusive_of_taxes invoice.inclusive_of_taxes
    # json.paid_amount precision_value invoice.paid_amount&.value
    json.paid_amount 120.0

    json.invoice_items do
      json.array!(invoice.invoice_items) do |item|
        json.rate item.rate
        json.quantity item.quantity
        json.tax item.tax
        json.discount item.discount
        json.category_id item.category_id
        json.tax_amount precision_value item.tax_amount&.value
        json.discount_amount precision_value item.discount_amount&.value
        json.amount precision_value item.amount&.value
        json.category_name item.category&.name
        json.id item.id
        json.description item.description
        json.total_amount precision_value item.net_amount&.value
        json.hsn_sac item.hsn_sac
      end
    end
  end

  json.actions do
    json.editable invoice.editable?
    json.navbar @result.navbar_actions
  end
end

