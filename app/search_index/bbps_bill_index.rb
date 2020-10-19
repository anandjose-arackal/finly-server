class BbpsBillIndex < SearchIndex::Model
  
  # def search_data
  #   {
  #       policy_id: policy_id,
  #       policy_name: policy&.name,
  #       status_id: status&.id,
  #       status_name: status&.name&.titleize,
  #       sequence_id: sequence_id,
  #       narration: note,
  #       invoice_number: bill_number,
  #       vendor_id: subscription.sequence_id,
  #       vendor_name: subscription.biller.biller_name,
  #       category_name: subscription.biller.biller_category_name,
  #       description: subscription.name,
  #       cost_center_names: [cost_center&.name],
  #       cost_center_codes: [cost_center&.cost_center_code],
  #       department_names: [department&.name],
  #       department_codes: [department&.department_code],
  #       location_names: [location&.name],
  #       location_codes: [location&.location_code],
  #       unique_transaction_references: [payments&.first&.bbps_bank_transaction&.bbps_ref_id]
  #   }.merge(collaborators)
  # end

  # index Indexes::Vp do
  #   include_associations(:policy, :status, {subscription: :biller}, :payments, :created_by)
  #
  #   document_type :utility_bills
  #   features [:procurement]
  #   permissions Docs::UtilityBills::Subscriptions::Index.permissions
  #   category :transactions
  #   route 'utility_bill/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:vendor_name, :sequence_id],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         policy_id: record.policy_id,
  #         policy_name: record.policy&.name,
  #         status_id: record.status&.id,
  #         status_name: record.status&.name&.titleize,
  #         sequence_id: record.sequence_id,
  #         narration: record.note,
  #         invoice_number: record.bill_number,
  #         vendor_id: record.subscription.sequence_id,
  #         vendor_name: record.subscription.biller.biller_name,
  #         category_name: record.subscription.biller.biller_category_name,
  #         description: record.subscription.name,
  #         cost_center_names: [record.cost_center&.name],
  #         cost_center_codes: [record.cost_center&.cost_center_code],
  #         department_names: [record.department&.name],
  #         department_codes: [record.department&.department_code],
  #         location_names: [record.location&.name],
  #         location_codes: [record.location&.location_code],
  #         unique_transaction_references: [record.payments&.first&.bbps_bank_transaction&.bbps_ref_id]
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end