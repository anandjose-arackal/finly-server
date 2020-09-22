json.payments do
  bank_transaction_class = current_user.company.feature_subscription.bank_transaction_class

  json.array!(@result.paginated_payments.include_for_index) do |payment|
    if payment.receiving_account&.is_a?(BbpsBiller)
      json.owner_name payment.receiving_account&.biller_name
      json.editable false # because a bbps bill can never be edited from the payment ticket screen
    elsif payment.receiving_account&.account_owner&.is_a?(YesBankVendor)
      json.owner_name payment.receiving_account&.account_owner&.display_name
      json.owner_business_name payment&.receiving_account&.account_owner&.business_name
      json.owner_trade_name payment&.receiving_account&.account_owner&.trade_name
      json.beneficiary_id payment.receiving_account&.account_owner&.id
      json.beneficiary_type (payment.receiving_account&.account_owner_type == "User" ? 1 : 2)
      json.disabled payment&.receiving_account&.disabled
      json.name payment.receiving_account&.name
      json.account_number payment.receiving_account&.account_number
      json.ifsc payment.receiving_account&.ifsc
    else
      json.owner_name payment.receiving_account&.account_owner&.name
      json.beneficiary_id payment.receiving_account&.account_owner&.id
      json.beneficiary_type (payment.receiving_account&.account_owner_type == "User" ? 1 : 2)
    end
    json.amount precision_value payment.amount_value
    json.payment_amount payment.amount_value
    json.net_amount precision_value payment.amount_value
    json.invoice_amount precision_value payment.invoice_amount
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.account_id payment.receiving_account&.id
    if payment.receiving_user.is_a?(User) || payment.receiving_user.is_a?(BbpsBillerSubscription) || payment.receiving_user.authorized
      json.beneficiary_type "authorized"
    else
      json.beneficiary_type "unauthorized"
    end
    json.system_messages do
      json.array! (payment.system_messages)
    end

    json.bank_reference_number payment.utr
    if payment.utr.blank?
      bank_transaction = bank_transaction_class.find_by(reference_payment_id: payment.id)
      json.bank_reference_number bank_transaction.bank_reference_number if bank_transaction.present?
    end

    credited_at = payment.reference_resources.first&.created_at&.strftime("%B %d, %Y - %H:%M:%S")

    if credited_at.blank?
      bank_transaction = bank_transaction_class.find_by(reference_payment_id: payment.id)
      credited_at = bank_transaction&.created_at&.strftime("%B %d, %Y - %H:%M:%S") if bank_transaction.present?
    end

    json.credited_at credited_at
    json.payment_notification_users payment&.parent&.payment_notification_users rescue nil
    json.category_id payment.category_id
    json.category_name payment.category&.name
    json.department_id payment.department_id
    json.department_name payment.department&.name
    json.cost_center_id payment.cost_center_id
    json.cost_center_name payment.cost_center&.name

    invoice = payment.invoice

    case payment.parent.class.name
    when 'PurchaseOrder'
      # since po advance can't be processed in tranches, for now just checking if there are other payments for it or not.
      # remaining_amount = (payment.parent.advance_amount&.value.to_f - payment.parent.advance_payments.map {|p| p.amount&.value.to_f if (PaymentStatus.all_except_failed.include? p.payment_status_id)}.compact.sum).round(2)
      remaining_amount = (payment.parent.advance_payments.map {|p| p.amount&.value.to_f if (PaymentStatus.all_except_failed.include? p.payment_status_id)}.compact.sum).round(2)
      retriable = payment.retriable? && remaining_amount <= 0
    when 'Invoice'
      retriable = payment.retriable? && payment.parent.payable
    when 'BeneficiaryPayment'
      retriable = payment.retriable?
    else
      retriable = payment.retriable?
    end

    json.retriable do
      json.retriable retriable
      json.change_mode payment.payment_order.failed?
    end

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
        json.invoice_type invoice.invoice_type&.name
        json.procurement_id invoice.procurement_id
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
        json.editable invoice.unpaid? || invoice.initiated?
        # adding the respective rates
        json.tax_rate precision_value invoice.tax_rate
        json.tds_rate precision_value invoice.tds_rate
        json.discount_rate precision_value invoice.discount_rate
        json.advance_rate precision_value invoice.advance_rate
        json.invoice_id invoice.invoice_id
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
        json.custom_field_config invoice.remaining_custom_field_config
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
    json.parent_details do
      unless payment.parent.nil?
        json.merge! payment.parent_details
        # json.payable_amount payment.get_payable_amount
        json.payable_amount precision_value payment.amount.value
      end
    end
  end
end

# # json.payments_count @result.ordered_payments.count
# # json.payments_status_ids @result.payment_status_ids
# # json.payment_status_id_count @result.payment_status_id_count
# json.payments_count @result.ordered_payments.size
# # non-paginated payments listing all payments in this payment order
# json.filter_count @result.filter_count
unless [168, 169, 174, 175, 118].include?(current_user.company_id)
  json.unpaid_payments do
    json.array!(@result.unpaid_payments.include_minimal_for_index) do |payment|
      if payment.receiving_account&.is_a?(BbpsBiller)
        json.name payment.receiving_account&.biller_name
      else
        json.owner_name payment.receiving_account&.account_owner&.name
        json.beneficiary_id payment.receiving_account&.account_owner&.id
        json.beneficiary_type (payment.receiving_account&.account_owner_type == "User" ? 1 : 2)
        json.name payment.receiving_account&.name
        json.account_number payment.receiving_account&.account_number
        json.disabled payment.receiving_account&.disabled
        json.ifsc payment.receiving_account&.ifsc
      end
      json.amount precision_value payment.amount_value
      json.payment_amount payment.amount_value
      json.net_amount precision_value payment.amount_value
      json.status payment.payment_status_name
      json.id payment.id
      json.note payment.note
      json.account_id payment.receiving_account&.id
      if payment.receiving_user&.is_a?(User) || payment.receiving_user&.is_a?(BbpsBillerSubscription) || payment.receiving_user&.authorized
        json.beneficiary_type "authorized"
      else
        json.beneficiary_type "unauthorized"
      end
    end
  end
end