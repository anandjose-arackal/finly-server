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
                :billing_address, :shipping_address, :invoice_id, :gstin_location_id

  json.transaction_service_period_from invoice.transaction_service_period_from&.strftime('%d/%m/%Y')
  json.transaction_service_period_to invoice.transaction_service_period_to&.strftime('%d/%m/%Y')
  json.po_number invoice.procurement&.purchase_order&.po_number

  json.po_advance invoice.po_advance
  json.po_prev_adjusted_advance invoice.po_prev_adjusted_advance
  json.po_adjusted_advance invoice.po_adjusted_advance
  json.advance_amount_required invoice.advance_amount_required

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
  json.discount_rate precision_value invoice.discount_rate
  json.advance_rate precision_value invoice.advance_rate
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

  # invoice items
  json.invoice_items do
    json.array!(invoice.invoice_items) do |item|
      json.extract! item, :id, :comment, :rate, :quantity, :tax, :discount, :category_id,
                    :unit_of_measurement, :description, :hsn_sac, :inventory_line_item_id, :tax_rate_id

      json.item_number item.inventory_line_item&.item_number rescue nil
      json.item_code item.inventory_line_item&.item_code rescue nil

      json.tax_amount precision_value item.tax_amount&.value
      json.discount_amount precision_value item.discount_amount&.value
      json.amount precision_value item.amount&.value
      json.category_name item.category&.name
      json.description item.description
      json.total_amount precision_value item.net_amount&.value
      json.taxable_amount precision_value item.taxable_amount&.value
    end
  end

  json.custom_fields invoice.custom_fields

  # json.vendor do
  #   json.name invoice.vendor&.name
  #   json.email invoice.vendor&.email
  #   json.id invoice.vendor&.id
  #
  #   json.selected_bank_account do
  #     json.account_number invoice.receiving_account&.account_number
  #     json.ifsc invoice.receiving_account&.ifsc
  #     json.name invoice.receiving_account&.name
  #     json.id invoice.receiving_account&.id
  #   end
  #
  #   if invoice.vendor&.bank_accounts.present?
  #     json.bank_accounts do
  #       json.array!(invoice.vendor&.bank_accounts) do |bank_account|
  #         json.id bank_account.id
  #         json.name bank_account.name
  #         json.account_number bank_account.account_number
  #         json.ifsc bank_account.ifsc
  #       end
  #     end
  #   end
  # end
  json.vendor invoice.vendor&.as_json
end

json.invoice_categories do
  json.array!(current_company.categories.vendor_payments_only) do |category|
    json.id category.id
    json.name category.name
  end
end
json.invoice_item_categories do
  json.array!(current_company.categories.inward_invoice_items_only) do |category|
    json.id category.id
    json.name category.name
  end
end
json.cost_centers do
  json.array!(current_company.cost_centers.with_application(RequestStoreUtil.current_app)) do |cost_center|
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
    json.id tds_slab.id
    json.name "#{tds_slab.tds}% - #{tds_slab.name} "
    json.tds tds_slab.tds
  end
end

json.attachments do
  json.array! invoice.attachments do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.file.url(:original, timestamp: false)
  end
end

json.gstin_locations do
  json.array! @result.gstin_locations do |gstin_location|
    json.extract! gstin_location, :id, :gstin, :poc_name, :poc_email, :poc_mobile_number, :location
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
          json.array! item[:reviewers] do |reviewer|
            json.extract! reviewer, :id, :exception, :threshold
            json.reviewer_details reviewer.reviewer.as_json
          end
        end
      end
    end
  end
end

json.reviewal_chain @result.invoice.get_reviewal_chain

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

json.tax_rates do
  json.array! @result.tax_rates do |tax_rate|
    json.merge! tax_rate.as_json
  end
end

json.locations do
  json.array! @result.locations do |location|
    json.extract! location, :id, :name, :gstin, :pan
    json.address location.address
  end
end

json.budgets do
  json.array! @result.budgets do |budget|
    json.extract! budget[:budget], :budgetable_id, :budgetable_type, :start_date, :id, :name, :purchase_order, :start_date, :end_date
    json.user budget[:budget].user.as_json
    json.spent_amount budget[:spent_amount]
    json.budget_amount budget[:budget].budget_amount.as_json
  end
end
