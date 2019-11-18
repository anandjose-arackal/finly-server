json.summary do
  json.processable_amount @result.processable_amount
  json.unprocessable_amount @result.unprocessable_amount
  json.scheduled_amount @result.scheduled_amount
  json.processable @result.processable?
  json.finly_money_balance @result.wallet_balance
  json.company_credits_balance @result.company_credits_balance
end

json.bank_accounts @result.bank_accounts

json.orders do
  json.array!(@result.result) do |payment_request|
    json.id payment_request[:id]
    json.name payment_request[:name]
    json.allowed payment_request[:allowed]
    json.next_date payment_request[:next_date]
    json.total_amount payment_request[:total_amount]
    json.created_at payment_request[:created_at]
    json.errors payment_request[:errors]
    json.selectable payment_request[:selectable]
    json.payment_mode payment_request[:payment_mode]
    json.initiating_user payment_request[:payment_request]&.owner&.name
    json.payments do
      json.array!(payment_request[:payment_request].payment_order.payments) do |payment|
        json.bank_payment_request do
          json.id payment.payment_order.bank_payment_request.id
          json.policy do
            json.id payment.payment_order.bank_payment_request.policy&.id
            json.name payment.payment_order.bank_payment_request.policy&.name
          end
          json.scheduled_at payment.payment_order.scheduled_at&.strftime "%d %b %Y"
          json.processed_at payment.payment_order.processed_at&.strftime "%d %b %Y"
        end
        json.name payment.receiving_account&.account_owner&.name
        json.account_number payment.receiving_account&.account_number
        json.ifsc payment.receiving_account&.ifsc
        json.net_amount precision_value payment.amount_value
        json.invoice_amount precision_value payment.invoice_amount
        json.status payment.payment_status_name
        json.id payment.id
        json.note payment.note
        json.account_id payment.receiving_account&.id
        json.beneficiary_id payment.receiving_account&.account_owner&.id
        json.beneficiary_type payment.receiving_account&.account_owner_type == "YesBankVendor" ? 2 : 1
        json.system_messages do
          json.array! (payment.system_messages)
        end
        json.bank_transfer_type payment.payment_mode&.upcase
        json.bank_reference_number payment.reference_resource&.bank_reference_number
        json.initiating_user do
          json.name payment.initiating_user&.name
          json.email payment.initiating_user&.email
          json.mobile_number payment.initiating_user&.mobile_number
        end
        # json.retriable payment.retriable?

        invoice = payment.invoice

        if payment.invoice.present?
          json.raw_amount precision_value invoice&.amount&.value
          json.original_amount precision_value invoice.original_amount&.value
          json.invoice do
            json.advance invoice.advance
            json.advance_amount invoice.advance_amount&.value
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
        else
          json.raw_amount precision_value payment.amount_value
          json.original_amount precision_value payment.amount_value
        end
      end
    end
  end
end