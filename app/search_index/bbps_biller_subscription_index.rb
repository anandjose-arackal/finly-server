class BbpsBillerSubscriptionIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :policy, :status, Indexes::VpRecords::Helpers::INCLUDE_COLLABORATORS,
                         :created_by, :location, :department, :cost_center, :biller

    serialize do |record|
      {
          vendor_name: record.biller.biller_name,
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status_id,
          status_name: record.status&.name,
          sequence_id: record.subscription_id,
          description: record.note,
          category_name: record.biller.biller_category_name,
          location_names: [record.location&.name],
          location_codes: [record.location&.location_code],
          department_names: [record.department&.name],
          department_codes: [record.department&.department_code],
          cost_center_names: [record.cost_center&.name],
          cost_center_codes: [record.cost_center&.cost_center_code]
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end