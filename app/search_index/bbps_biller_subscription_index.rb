class BbpsBillerSubscriptionIndex < SearchIndex::Model

  index Indexes::Vp do
    include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS,
                         :created_by, :location, :department, :cost_center, :biller

    document_type :utility_subscriptions
    features :utility_bills_enabled
    permissions Docs::UtilityBills::Subscriptions::Index.permissions
    category :masters
    route 'utility_bill_master/{{record_id}}/params={}'
    layout(
        {
            fixed_left: [:description, :sequence_id],
            fixed_right: [:created_by_name, :created_by_email, :status_name]
        }
    )

    record_type do |record|
      'utility_subscriptions'
    end

    serialize do |record|
      {
          vendor_name: record.biller.biller_name,
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status_id,
          status_name: record.status&.name&.titleize,
          sequence_id: record.sequence_id,
          description: record.name,
          narration: record.note,
          category_name: record.biller.biller_category_name,
          location_names: [record.location&.name],
          location_codes: [record.location&.location_code],
          department_names: [record.department&.name],
          department_codes: [record.department&.department_code],
          cost_center_names: [record.cost_center&.name],
          cost_center_codes: [record.cost_center&.cost_center_code]
      }.merge(Indexes::Vp::Helpers::Collaborators(record))
    end

  end

end