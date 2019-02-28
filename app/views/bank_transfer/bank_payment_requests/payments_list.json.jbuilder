json.payments do
  json.array!(@result.paginated_payments.include_for_index) do |payment|
    json.owner_name payment.receiving_account&.account_owner&.name
    json.name payment.receiving_account&.name
    json.account_number payment.receiving_account&.account_number
    json.ifsc payment.receiving_account&.ifsc
    json.amount precision_value payment.amount_value
    json.payment_amount payment.amount_value
    json.net_amount precision_value payment.amount_value
    json.invoice_amount precision_value payment.invoice_amount
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.account_id payment.receiving_account&.id
    json.beneficiary_id payment.receiving_account&.account_owner&.id
    json.beneficiary_type (payment.receiving_account&.account_owner_type == "User" ? 1 : 2)
    if payment.receiving_user.is_a?(User) || payment.receiving_user.authorized
      json.beneficiary_type "authorized"
    else
      json.beneficiary_type "unauthorized"
    end
    json.system_messages do
      json.array! (payment.system_messages)
    end
    json.bank_reference_number payment.reference_resource&.bank_reference_number
    json.retriable do
      json.retriable payment.retriable?
      json.change_mode payment.payment_order.failed?
    end
    json.category_id payment.category_id
    json.category_name payment.category&.name
    json.department_id payment.department_id
    json.department_name payment.department&.name

    invoice = payment.invoice

    if payment.invoice.present?
      json.raw_amount precision_value invoice&.amount&.value
      # conditionally set the original amount as invoice amount is there are line items
      if payment.invoice&.invoice_items.present?
        json.original_amount precision_value invoice.amount&.value
      else
        json.original_amount precision_value invoice.original_amount&.value
      end
      json.invoice do
        json.id invoice.id
        json.advance invoice.advance
        json.advance_amount precision_value invoice.advance_amount&.value
        json.tax_amount precision_value invoice.tax_amount&.value
        json.tds_amount precision_value invoice.tds_amount&.value
        json.tax precision_value invoice.tax
        json.tds precision_value invoice.tds
        json.gst_type_id invoice.gst_type_id
        json.tax_type_id invoice.tax_type_id
        json.tds_type_id invoice.tds_type_id
        json.discount_amount precision_value invoice.discount_amount&.value
        json.discount precision_value invoice.discount
        json.date invoice.date
        json.discount_type_id invoice.discount_type_id
        json.due_date invoice.due_date
        json.invoice_number invoice.invoice_number
        json.inclusive_of_taxes invoice.inclusive_of_taxes
        json.freight_amount invoice.freight_amount&.value
        json.roundoff_amount invoice.roundoff_amount
        json.net_payable_amount invoice.balance_due&.value
        json.balance_due invoice.balance_due&.value
        json.taxable_amount precision_value invoice.gross_amount&.value
        json.editable invoice.unpaid?
        # adding the respective rates
        json.tax_rate precision_value invoice.tax_rate
        json.tds_rate precision_value invoice.tds_rate
        json.discount_rate precision_value invoice.discount_rate
        json.advance_rate precision_value invoice.advance_rate
        #############################
        json.invoice_attachment do
          json.url invoice.invoice_attachments.first&.attached_file&.url
          json.thumb invoice.invoice_attachments.first&.attached_file&.url(:thumb)
          json.content_type invoice.invoice_attachments.first&.attached_file&.content_type
          json.file_name invoice.invoice_attachments.first&.attached_file&.original_filename
        end
        json.net_amount precision_value invoice.net_amount&.value
        json.gross_amount precision_value invoice.gross_amount&.value
        json.custom_fields do
          json.array! invoice.custom_fields
        end
        json.category_id invoice.category_id
        json.category_name invoice.category&.name

        json.cost_center_id invoice.cost_center_id
        json.cost_center_name invoice.cost_center&.name

        json.tds_slab_id invoice.tds_slab_id
        json.tds_slab_name invoice.tds_slab&.name
        json.tds_rate invoice.tds

        # invoice amounts total
        json.item_amounts_total invoice.item_amounts_total

        # paid amount for this invoice
        json.paid_amount invoice.payments.successful.joins(:amount).sum(:value)
        json.remaining_amount (invoice.balance_due&.value.to_f - invoice.payments.successful.joins(:amount).sum(:value))

        #

        json.invoice_items do
          json.array!(invoice.invoice_items) do |item|
            json.rate item.rate
            json.quantity item.quantity
            json.tax item.tax
            json.discount item.discount
            json.category_id item.category_id
            json.category_name item.category&.name
            json.tax_amount precision_value item.tax_amount&.value
            json.discount_amount precision_value item.discount_amount&.value
            json.amount precision_value item.amount&.value
            json.id item.id
            json.description item.description
            json.total_amount precision_value item.net_amount&.value
            json.hsn_sac item.hsn_sac
            json.taxable_amount precision_value item.taxable_amount&.value
          end
        end
      end
    else
      json.raw_amount precision_value payment.amount_value
      json.original_amount precision_value payment.amount_value
      json.invoice do
        json.net_amount precision_value payment.amount&.value
        json.roundoff_amount 0
        json.balance_due payment.amount&.value
      end
    end

    json.parent_type payment.parent_type
    json.parent_id payment.parent_id
    # json.invoice_details payment.invoice.invoice_amount_details
    json.parent_details payment.parent_details

  end
end



# json.payments_count @result.ordered_payments.count
# json.payments_status_ids @result.payment_status_ids
# json.payment_status_id_count @result.payment_status_id_count

json.payments_count @result.ordered_payments.size

# non-paginated payments listing all payments in this payment order
json.filter_count @result.filter_count
unless current_company.id == 118
json.unpaid_payments do
  json.array!(@result.unpaid_payments.include_minimal_for_index) do |payment|
    json.owner_name payment.receiving_account&.account_owner&.name
    json.name payment.receiving_account&.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.amount precision_value payment.amount_value
    json.payment_amount payment.amount_value
    json.net_amount precision_value payment.amount_value
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.account_id payment.receiving_account.id
    json.beneficiary_id payment.receiving_account.account_owner&.id
    json.beneficiary_type (payment.receiving_account.account_owner_type == "User" ? 1 : 2)
    if payment.receiving_user.is_a?(User) || payment.receiving_user.authorized
      json.beneficiary_type "authorized"
    else
      json.beneficiary_type "unauthorized"
    end
  end
end
end
