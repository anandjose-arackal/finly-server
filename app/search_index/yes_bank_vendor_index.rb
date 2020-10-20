class YesBankVendorIndex < SearchIndex::Model

  index Indexes::Vp do
    include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS, :gstin_locations, :created_by

    document_type :vendors
    permissions Masters::Vendors::Index.permissions
    category :masters
    route 'vendor/{{record_id}}/params={}'
    layout(
        {
            fixed_left: [:vendor_name, :sequence_id],
            fixed_right: [:created_by_name, :created_by_email, :status_name]
        }
    )

    serialize do |record|
      {
          vendor_name: record.business_name,
          vendor_trade_name: record.trade_name,
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status_id,
          status_name: record.status&.name&.titleize,
          sequence_id: record.vendor_id,
          description: record.description,
          tax_id: record.pan,
          tax_registration_number: record.gstin_locations.pluck(:gstin).join(", "),
      }.merge(Indexes::Vp::Helpers::Collaborators(record))
    end

  end

end