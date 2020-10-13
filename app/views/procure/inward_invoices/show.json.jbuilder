# json.extract! @result.invoice, :id, :invoice_number
#
# if @result.invoice.vendor.present?
#   json.vendor do
#     json.extract! invoice.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
#   end
# end
#
# json.items do
#   json.array! @result.invoice.invoice_items do |item|
#     json.extract! item, :id, :description, :hsn_sac, :quantity,
#                   :rate, :tax, :discount
#     json.tax_amount do
#       json.value item.tax_amount&.value
#       json.id item.tax_amount&.id
#       json.currency_id item.tax_amount&.currency&.id
#     end
#     json.discount_amount do
#       json.value item.discount_amount&.value
#       json.id item.discount_amount&.id
#       json.currency_id item.discount_amount&.currency&.id
#     end
#     json.total_amount do
#       json.value item.amount&.value
#       json.id item.amount&.id
#       json.currency_id item.amount&.currency&.id
#     end
#   end
# end

invoice = @result.invoice

json.purchase_order_policy_id invoice.procurement&.purchase_order&.policy&.id
json.actions @result.actions

json.status do
  json.extract! invoice.invoice_status, :id, :name
end

json.invoice_payment_status invoice.invoice_payment_status

# do
#   if current_user.vendor_payment_creditor?
#     json.make_payment true
#   end
#   json.editable invoice.unpaid?
#   json.destroyable invoice.unpaid?
# end

if invoice.vendor.present?
  json.vendor invoice.vendor.as_json
end

json.invoice do
  # conditionally set the original amount as invoice amount is there are line items
  json.extract! invoice, :id, :invoice_number, :payment_term_id, :location_id, :delivery_location_id, :department_id, :sub_department_id, :policy_id, :procurement_id,
                :billing_address, :shipping_address, :invoice_id, :gstin_location_id,
                :cost_allocation_items, :narration, :discount_type_id, :rcm_enabled

  json.invoice_type invoice.invoice_type&.name
  json.transaction_service_period_from invoice.transaction_service_period_from&.strftime('%d/%b/%Y')
  json.transaction_service_period_to invoice.transaction_service_period_to&.strftime('%d/%b/%Y')
  # json.po_number invoice.procurement&.purchase_order&.po_number
  json.po_number invoice.po_number
  json.created_from_payment_agreement invoice.payment_agreement_id.present?
  json.agreement_number invoice&.payment_agreement&.get_agreement_number
  json.payment_agreement_id invoice.payment_agreement_id
  json.po_advance invoice.po_advance
  json.po_prev_adjusted_advance invoice.po_prev_adjusted_advance
  json.po_adjusted_advance invoice.po_adjusted_advance
  json.advance_amount_required invoice.advance_amount_required
  json.po_advance_tds_present (@result.respond_to?('purchase_order')) ? @result.purchase_order&.advance_tds_slab.present? : false
  json.user invoice.created_by.as_json rescue nil
  json.available_credits invoice.available_credits

  if invoice&.invoice_items.present?
    json.original_amount precision_value invoice.amount&.value
  else
    json.original_amount precision_value invoice.original_amount&.value
  end
  json.raw_amount precision_value invoice&.amount&.value
  json.advance_amount precision_value invoice.advance_amount&.value
  json.tax_amount precision_value invoice.tax_amount&.value
  json.tds_amount precision_value invoice.tds_amount&.value
  json.tax precision_value invoice.tax
  json.tds precision_value invoice.tds
  json.gst_type_id invoice.gst_type_id
  json.discount_amount precision_value invoice.discount_amount&.value
  json.discount precision_value invoice.discount
  json.advance invoice.advance
  json.freight_amount invoice.freight_amount&.value
  json.date invoice.date
  json.due_date invoice.due_date
  json.invoice_number invoice.invoice_number
  json.inclusive_of_taxes invoice.inclusive_of_taxes
  json.freight_amount invoice.freight_amount&.value
  json.roundoff_amount invoice.roundoff_amount
  json.balance_due invoice.balance_due&.value
  json.taxable_amount precision_value invoice.gross_amount&.value
  # adding the respective rates
  json.tax_rate precision_value invoice.tax_rate
  json.tds_rate precision_value invoice.tds_rate
  # json.discount_rate precision_value invoice.discount_rate
  json.discount_rate precision_value ((invoice.discount_amount&.value / invoice.item_amounts_total) * 100).round(2) rescue 0
  json.advance_rate precision_value invoice.advance_rate
  json.variable_periodic_invoice @result.variable_periodic_invoice
  #############################
  json.invoice_attachment do
    json.url invoice.invoice_attachments.first&.attached_file&.url(:original, timestamp: false)
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

  json.department_attributes do
    json.id invoice.department_id
    json.name invoice&.department&.name
  end

  json.policy_attributes do
    json.id invoice.policy_id
    json.name invoice.policy&.name
  end

  json.sub_department_attributes do
    json.id invoice.sub_department_id
    json.name invoice.sub_department&.name
  end

  json.cost_center_attributes do
    json.id invoice.cost_center_id
    json.name invoice.cost_center&.name
  end

  json.delivery_location_attributes invoice.delivery_location&.as_json rescue nil
  json.gstin_location_attributes invoice.gstin_location&.as_json rescue nil

  json.tds_slab_id invoice.tds_slab_id
  json.tds_slab_name invoice.tds_slab&.name
  json.tds_rate invoice.tds

  json.note invoice.note

  json.invoice_status_id invoice.invoice_status_id
  json.invoice_status_name invoice.invoice_status&.name&.humanize

  # invoice amounts total
  json.item_amounts_total invoice.item_amounts_total&.round(2)

  json.net_payable_amount invoice.balance_due&.value
  json.paid_amount invoice.payments.successful.joins(:amount).sum(:value)
  json.remaining_amount (invoice.balance_due&.value.to_f - invoice.payments.successful.joins(:amount).sum(:value))

  json.credit_note_adjustments do
    json.array! invoice.credit_note_adjustments do |cna|
      json.id cna.id
      json.credit_note_id cna.credit_note.id
      json.credit_note_number cna.credit_note.credit_note_number
      json.credit_note_sequence_id cna.credit_note.sequence_id
      json.amount cna.amount.as_json
    end
  end

  # invoice items
  json.invoice_items do
    json.array!(invoice.invoice_items) do |item|
      json.extract! item, :id, :comment, :rate, :quantity, :tax, :discount,
                    :unit_of_measurement, :description, :hsn_sac, :inventory_line_item_id, :tax_rate_id, :department_id, :cost_center_id, :sgst, :cgst, :igst,
                    :purchase_order_item_id

      json.category_id item&.category_id rescue nil
      json.item_number item&.inventory_line_item&.item_number rescue nil
      json.gl_code item&.category.gl_code rescue nil
      json.tds_applicable (item&.tds_applicable) ? "yes" : "no"


      json.tax_amount precision_value item.tax_amount&.value
      json.discount_amount precision_value item.discount_amount&.value
      json.discount_rate precision_value((item.discount_amount&.value/(item.rate * item.quantity) * 100)) rescue 0
      json.amount precision_value item.amount&.value
      json.category_name item&.category&.name
      json.description item.description
      json.total_amount precision_value item.net_amount&.value
      json.taxable_amount precision_value item.taxable_amount&.value
      json.billable_amount precision_value item.billable_amount&.value
      json.department_attributes do
        json.id item.department_id
        json.name item&.department&.name
      end
      json.cost_center_attributes do
        json.id item.cost_center_id
        json.name item&.cost_center&.name
      end
      json.category_attributes do
        json.id item&.category_id
        json.name item&.category&.name
      end


      product = ""
      case item.inventory_line_item&.product_type_id
      when ProductType.id_for(:goods)
        product = "goods"
        json.purchase_order_accepted_quantity item.purchase_order_item&.accepted
      when ProductType.id_for(:service)
        product = "service"
        json.purchase_order_accepted_quantity item.quantity
      end      
      json.product_type product
    end
  end

  json.custom_fields invoice.custom_fields

  json.vendor do
    json.extract! invoice&.vendor

    json.selected_bank_account do
      json.account_number invoice.receiving_account&.account_number
      json.ifsc invoice.receiving_account&.ifsc
      json.name invoice.receiving_account&.name
      json.id invoice.receiving_account&.id
      json.disabled invoice.receiving_account&.disabled
    end

    if invoice.vendor&.bank_accounts.present?
      json.bank_accounts do
        json.array!(invoice.vendor&.bank_accounts.enabled) do |bank_account|
          json.id bank_account.id
          json.name bank_account.name
          json.account_number bank_account.account_number
          json.ifsc bank_account.ifsc
          json.default bank_account.default_account
          json.selected invoice.receiving_account&.id == bank_account.id
          json.disabled bank_account.disabled
        end
      end
    end
  end
end

json.invoice_categories current_company.categories.vendor_payments_only.active
json.invoice_item_categories current_company.categories.inward_invoice_items_only.active

json.cost_centers do
  # json.array!(current_company.cost_centers.with_application(RequestStoreUtil.current_app)) do |cost_center|
  json.array! @result.cost_centers do |cost_center|
    json.id cost_center.id
    json.name cost_center.name
  end
end

# json.departments do
#   json.array! @result.departments do |dept|
#     json.extract! dept, :id, :name, :cost_center_id
#   end
# end

json.departments do
  json.array! @result.departments do |department|
    json.merge! department.as_json(tree: true)
  end
end

json.sub_departments do
  json.array! @result.sub_departments do |dept|
    json.extract! dept, :id, :name, :cost_center_id
    json.parent_id dept.ancestry&.to_i
  end
end
json.tds_slabs do
  json.array!(current_company.tds_slabs) do |tds_slab|
    if (tds_slab == invoice.tds_slab) || !tds_slab.deleted?
      json.id tds_slab.id
      json.name "#{tds_slab.tds}% - #{tds_slab.name} "
      json.tds tds_slab.tds
      json.preferred @result.invoice.vendor.tds_rates.pluck(:id).include?(tds_slab.id) rescue false
    end
  end
end


json.attachments do
  json.array! invoice.attachments.reject {|attachment| attachment.file_file_size.nil?} do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.file.url(:original, timestamp: false)
    json.content_type attachment&.file_content_type
  end
end

json.gstin_locations do
  json.array! @result.gstin_locations do |gstin_location|
    json.extract! gstin_location, :id, :gstin, :poc_name, :poc_email, :poc_mobile_number, :location, :address, :state_code
    json.location "#{gstin_location&.location.to_s} - #{gstin_location.state&.name&.to_s}"
  end
end

json.reviewal_chains do
  json.array! @result.reviewal_chains do |chain|
    json.policy_id chain[:policy_id]
    json.reviewal_chain do
      json.array! chain[:reviewal_chain] do |item|
        json.level_number item[:level_number]
        json.level_name item[:level_name]
        json.level_id item[:level_id]
        if item[:selected_reviewer].present?
          json.selected_reviewer do
            json.reviewer_details item[:selected_reviewer].as_json
            json.threshold item[:selected_reviewer_threshold]
          end
        end
        # json.selected_reviewer item[:selected_reviewer]&.as_json
        # json.selected_reviewer_threshold item[:selected_reviewer_threshold]
        json.reviewers do
          # if current_company.present? && (current_company.id == 2 || current_company.id == 156)
          #   json.array! item[:reviewer_data] do |data|
          #     json.id data[:id]
          #     json.exception data[:exception]
          #     json.threshold data[:threshold]
          #     json.reviewer_details do
          #       min = MathUtil.number_with_rupee_delimiter(data[:min])
          #       max = (data[:max].to_i == 99999999999999 ? '∞' : MathUtil.number_with_rupee_delimiter(data[:max]))
          #       json.name "#{data[:reviewer_name]}(#{min} - #{max})"
          #       json.id data[:reviewer_id]
          #     end
          #   end
          # else
            json.array! item[:reviewers] do |reviewer|
              json.extract! reviewer, :id, :exception, :threshold, :min, :max
              json.reviewer_details reviewer.reviewer.as_json
            end
          # end
        end
      end
    end
  end
end

if @result.invoice.procurement.purchase_order.present?
  json.reviewal_chain @result.invoice.get_reviewal_chain('PoInvoiceProvider')
elsif @result.invoice.payment_agreement_id.present?
  json.reviewal_chain @result.invoice.get_reviewal_chain('AgreementInvoiceProvider')
else
  json.reviewal_chain @result.invoice.get_reviewal_chain('NonPoInvoiceProvider')
end

json.comments do
  json.array! invoice.comments do |comment|
    json.extract! comment, :id, :body
    json.created_at comment.created_at.strftime("%b %d, %y")
    json.created_at_time comment.created_at.strftime("%I:%m%p")
    json.user do
      json.name comment.user&.name

      json.id comment.user&.id
    end
  end
end

json.policies do
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name
  end
end

json.bank_payment_request_policies do
  json.array! @result.bank_payment_request_policies do |policy|
    json.extract! policy, :id, :name
  end
end

json.tax_rates do
  json.array! @result.tax_rates do |tax_rate|
    json.merge! tax_rate.as_json
  end
end

json.locations do
  json.array! @result.locations do |location|
    json.extract! location, :id, :name, :gstin, :pan, :state_code
    json.address location.address
  end
end

# json.budgets do
#   json.array! @result.budgets do |budget|
#     json.extract! budget[:budget], :budgetable_id, :budgetable_type, :start_date, :id, :name, :purchase_order, :start_date, :end_date
#     json.user budget[:budget].user.as_json
#     json.spent_amount budget[:spent_amount]
#     json.budget_amount budget[:budget].budget_amount.as_json
#   end
# end

json.transfer_modes current_company.transfer_modes.as_json
json.budgets @result.budgets