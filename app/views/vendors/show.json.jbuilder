json.id @result.vendor.id
json.vendor_approval_workflow @result.vendor_approval_workflow
json.vendor do
  json.extract! @result.vendor, :id, :name, :email, :mobile_number
  if @result.vendor.is_a?(YesBankVendor)
    json.payment_term @result.vendor.payment_term
    json.currency @result.vendor.currency
    json.business_name @result.vendor.business_name
    json.address @result.vendor.address
    json.authorized @result.vendor.authorized
    json.description @result.vendor.description
    json.editable_details (@result.user.permission.create_beneficiaries || @result.user.vendor_payments_admin?)
    json.pan @result.vendor.pan
    json.gst @result.vendor.gst
    json.tin @result.vendor.tin
    json.state_code_id @result.vendor.state_code_id
    json.state_code_name @result.vendor.state_code&.full_name
    json.created_by @result.vendor.created_by&.name
    json.vendor_id @result.vendor.vendor_id
    json.tds_rates do
      json.array! @result.vendor.tds_rates do |tds_rate|
        json.extract! tds_rate, :id, :name, :tds
      end
    end
  else
    json.editable_details false
  end
  json.created_at @result.vendor.created_at.strftime "%b %d %y"
end

json.reviewal_chain @result.vendor.get_reviewal_chain
json.status do
  json.merge! @result.vendor.status&.as_json
end
json.bank_accounts do
  json.array!(@result.bank_accounts) do |bank_account|
    json.account_number bank_account.account_number
    json.confirm_account_number bank_account.account_number
    json.ifsc bank_account.ifsc
    json.id bank_account.id
    json.name bank_account.name
    json.default bank_account.default_account
  end
end

json.gstin_locations do 
  json.array!(@result.vendor.gstin_locations) do |gstin_location|
    json.extract! gstin_location, :id, :gstin, :poc_name, :poc_mobile_number, :poc_email, :poc_fax, :poc_designation, :state_id, :location_id
    if gstin_location.gstin_master.present?
      json.extract! gstin_location.gstin_master, :id, :gstin, :legal_name_of_business, :state, :date_of_registration,
                  :constitution_of_business, :taxpayer_type, :status, :api_response, :address
    end
  end
end
json.transactions do
  json.array!(@result.receiving_transactions) do |payment|
    json.extract! payment, :id, :note
    json.reference_id payment.reference_resource&.bank_reference_number
    json.amount payment.amount.value
    json.date payment.date
    json.bank_payment_request_id payment.payment_order&.bank_payment_request&.id
    json.payment_mode payment.payment_mode&.upcase
    json.account_number payment.receiving_account&.account_number
    json.ifsc payment.receiving_account&.ifsc
    json.initiating_user_name payment.initiating_user&.name
    json.payment_status payment.payment_status_name
  end
end
if @result.vendor.is_a?(YesBankVendor)
  json.attachments do
    json.array! @result.vendor.vendor_attachments do |attachment|
      json.id attachment.id
      json.uid attachment.id
      json.url attachment.attached_file&.url
      json.thumb attachment.attached_file&.url(:thumb)
      json.file_type attachment.attached_file_content_type
      json.attachment_type attachment.attachment_type
    end
  end

  json.vendor_type do
    json.id @result.vendor.vendor_type&.id
    json.name @result.vendor.vendor_type&.name
  end


  json.procurement_data do
    json.purchase_orders do
      json.array! @result.procurement_data[:purchase_orders] do |po|
        json.extract! po, :id, :po_number, :procurement_id
        json.created_by po.user&.name
        json.created_at po.created_at&.strftime("%d-%b-%Y")
        json.amount po.balance_amount&.value
      end
    end

    json.non_po_invoices do
      json.array! @result.procurement_data[:non_po_invoices] do |invoice|
        json.extract! invoice, :id, :invoice_id, :invoice_number, :procurement_id
        json.created_by invoice.created_by&.name
        json.created_at invoice.created_at&.strftime("%d-%b-%Y")
        json.amount invoice.net_amount&.value
      end
    end

 end
end

json.actions @result.actions

json.custom_fields do
  json.array! @result.custom_fields
end

if @result.vendor.policy.present?
  json.policy do 
    json.extract! @result.vendor&.policy, :id, :name  
  end
end

json.edit_config do
  json.vendor_approval_workflow @result.edit_config.vendor_approval_workflow
  json.codes do
    json.array! @result.edit_config.states, :id, :name
  end
  json.vendor_types do
    json.array! @result.edit_config.vendor_types, :id, :name
  end

  json.payment_terms do
    json.array! @result.edit_config.payment_terms, :id, :name, :description
  end

  json.currencies do
    json.array! @result.edit_config.currencies do |currency|
      json.merge! currency.as_json
    end
  end

  # json.tds_rates do
  #   json.array! @result.edit_config.vendor_tds_rates do |vtr|
  #     json.vendor_tds_rate_id vtr.id
  #     json.extract! vtr.tds_rate, :id, :name, :tds
  #   end
  # end

  json.tds_rates do
    json.array! @result.edit_config.tds_rates do |tds_rate|
      # json. vtr.id
      json.extract! tds_rate, :id, :name, :tds
    end
  end

  json.custom_fields_config @result.edit_config.field_configurations

  json.policies do
    json.array! @result.edit_config.policies do |policy|
      json.extract! policy, :id, :name
    end
  end

  json.locations do
    json.array! @result.edit_config.locations do |location|
      json.extract! location, :id, :name
    end
  end


  json.reviewal_chains do
    json.array! @result.edit_config.reviewal_chains do |chain|
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

end

