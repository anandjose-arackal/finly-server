json.extract! @result.purchase_order, :id, :po_number, :delivery_date, :gst_type_id,
              :inclusive_of_taxes, :roundoff_total_enabled, :roundoff_amount, :location_id, :delivery_location_id,
              :payment_term_id, :procurement_term_text, :policy_id, :department_id, :sub_department_id, :cost_center_id,
              :billing_address, :shipping_address, :note, :gstin_location_id, :cost_allocation_items
json.vendor @result.purchase_order.vendor.as_json

json.vendor do
  json.extract! @result.purchase_order&.vendor

  json.selected_bank_account do
    json.account_number @result.purchase_order.bank_account&.account_number
    json.ifsc @result.purchase_order.bank_account&.ifsc
    json.name @result.purchase_order.bank_account&.name
    json.id @result.purchase_order.bank_account&.id
  end

  if @result.purchase_order.vendor&.bank_accounts.present?
    json.bank_accounts do
      json.array!(@result.purchase_order.vendor&.bank_accounts) do |bank_account|
        json.id bank_account.id
        json.name bank_account.name
        json.account_number bank_account.account_number
        json.ifsc bank_account.ifsc
      end
    end
  end
end

json.actions @result.actions

if @result.purchase_order.advance_payments&.present?
  json.show_advance_payments true
  json.advance_payments_count @result.purchase_order.advance_payments.count
end

json.status do
  json.extract! @result.purchase_order&.status, :id, :name
end
json.total_before_tax do
  json.id @result.purchase_order.total_before_tax&.id
  json.value @result.purchase_order.total_before_tax&.value&.round(2)
  json.currency_id @result.purchase_order.total_before_tax&.currency&.id
end
json.advance_amount do
  json.id @result.purchase_order.advance_amount&.id
  json.total @result.purchase_order.total_adv_amount
  json.value @result.purchase_order.advance_amount&.value
  json.tds_amount @result.purchase_order.advance_tds_amount&.value
  json.tds_slab_id @result.purchase_order.advance_tds_slab_id
  json.tds_slab_name @result.purchase_order.advance_tds_slab&.name
  json.currency_id @result.purchase_order.advance_amount&.currency&.id
  json.due_date @result.purchase_order.due_date&.strftime("%e-%b-%Y")
  json.status do
    json.id @result.purchase_order.advance_amount_status&.id
    json.name @result.purchase_order.advance_amount_status&.name
  end
  json.advance_amount_required @result.purchase_order.advance_amount_required

  json.requested_advance_amount @result.purchase_order.requested_advance_amount&.value
  json.advance_amount @result.purchase_order.advance_amount&.value
  json.tds_amount @result.purchase_order.advance_tds_amount&.value
end
json.tax do
  json.value @result.purchase_order.tax_amount&.value&.round(2)
  json.id @result.purchase_order.tax_amount&.id
  json.currency_id @result.purchase_order.tax_amount&.currency&.id
end
json.total_after_tax do
  json.id @result.purchase_order.total_after_tax&.id
  json.value @result.purchase_order.total_after_tax&.value&.round(2)
  json.currency_id @result.purchase_order.total_after_tax&.currency&.id
end
json.discount do
  json.value @result.purchase_order.discount_amount&.value&.round(2)
  json.id @result.purchase_order.discount_amount&.id
  json.currency_id @result.purchase_order.discount_amount&.currency&.id
end
json.balance_due do
  json.value @result.purchase_order.balance_amount&.value&.round(2)
  json.id @result.purchase_order.balance_amount&.id
  json.currency_id @result.purchase_order.balance_amount&.currency&.id
end

json.items do
  json.array! @result.purchase_order.items do |item|
    json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :hsn_sac, :quantity,
                  :unit_of_measurement,
                  :rate, :tax, :tds, :discount, :delivery_date, :comment, :tax_rate_id, :department_id, :cost_center_id
    
    json.item_number item.inventory_line_item&.item_number rescue nil
    json.gl_code item.inventory_line_item&.item_code rescue nil

    json.tax_amount do
      json.value item.tax_amount&.value&.round(2)
      json.id item.tax_amount&.id
      json.currency_id item.tax_amount&.currency&.id
    end
    json.discount_amount do
      json.value item.discount_amount&.value&.round(2)
      json.id item.discount_amount&.id
      json.currency_id item.discount_amount&.currency&.id
    end
    json.total_amount do
      json.value item.total_amount&.value&.round(2)
      json.id item.total_amount&.id
      json.currency_id item.total_amount&.currency&.id
    end
  end
end

# Removing quotations data from PO for now
# json.quotations do
#   json.array! @result.purchase_order.quotations do |quote|
#     json.merge! quote.as_json
#     json.attachments do
#       json.array! quote.attachments do |attachment|
#         json.extract! attachment, :id, :description
#         json.file_name attachment.file_file_name
#         json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
#         json.url attachment.file.url(:original, timestamp: false)
#       end
#     end
#   end
# end

json.attachments do
  json.array! @result.purchase_order.attachments do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.file.url(:original, timestamp: false)
    json.content_type attachment.file_content_type
  end
end

json.comments do
  json.array! @result.purchase_order.comments do |comment|
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

json.cost_centers do
  json.array! @result.cost_centers do |cost_center|
    json.extract! cost_center, :id, :name
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
        json.timestamp item[:timestamp]&.strftime("%Y-%m-%d  %H:%M:%s")
        if item[:selected_reviewer].present?
          json.selected_reviewer do
            json.reviewer_details item[:selected_reviewer].as_json
            json.threshold item[:selected_reviewer_threshold]
          end
        end
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

json.reviewal_chain @result.purchase_order.get_reviewal_chain

json.budgets do
  json.array! @result.budgets do |budget|
    json.extract! budget[:budget], :budgetable_id, :budgetable_type, :start_date, :id, :name, :purchase_order, :start_date, :end_date
    json.user budget[:budget].user.as_json
    json.spent_amount budget[:spent_amount]
    json.budget_amount budget[:budget].budget_amount.as_json
  end
end

json.custom_fields do
  json.array! @result.purchase_order.custom_fields
end

json.tax_rates do
  json.array! @result.tax_rates do |tax_rate|
    json.merge! tax_rate.as_json
  end
end

json.locations do
  # json.array! @result.locations do |location|
    # json.extract! location, :id, :name, :gstin, :pan
    # json.address location.address
  json.array! @result.locations do |location|
    json.merge! location.as_json(tree: true)
  end


  # end
end

json.gstin_locations do
  json.array! @result.gstin_locations do |gstin_location|
    json.extract! gstin_location, :id, :gstin, :poc_name, :poc_email, :poc_mobile_number, :location
    json.location (gstin_location.location.to_s + " - " + gstin_location.state&.name&.to_s)
  end
end

json.tds_slabs do
    json.array!(@result.tds_slabs.tds_slabs) do |tds_slab|
      json.id tds_slab.id
      json.name tds_slab.name
      json.tds tds_slab.tds
    end
end
