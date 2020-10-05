class BbpsBillIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations(:policy, :status, {subscription: :biller}, {payments: :bbps_bank_transaction}, :created_by)

    serialize do |record|
      {
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status&.id,
          status_name: record.status&.name&.titleize,
          sequence_id: record.bill_id,
          narration: record.note,
          invoice_number: record.bill_number,
          vendor_id: record.subscription.subscription_id,
          vendor_name: record.subscription.biller.biller_name,
          category_name: record.subscription.biller.biller_category_name,
          description: record.subscription.name,
          cost_center_names: [record.cost_center&.name],
          cost_center_codes: [record.cost_center&.cost_center_code],
          department_names: [record.department&.name],
          department_codes: [record.department&.department_code],
          location_names: [record.location&.name],
          location_codes: [record.location&.location_code],
          unique_transaction_references: [record.payments&.first&.bbps_bank_transaction&.bbps_ref_id]
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end