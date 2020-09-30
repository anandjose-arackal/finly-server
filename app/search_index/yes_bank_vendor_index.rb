class YesBankVendorIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :policy, :status, Indexes::VpRecords::Helpers::INCLUDE_COLLABORATORS, :gstin_locations, :created_by

    record_type do |record|
      'vendors'
    end

    serialize do |record|
      {
          vendor_name: record.business_name,
          vendor_trade_name: record.trade_name,
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status_id,
          status_name: record.status&.name,
          sequence_id: record.vendor_id,
          description: record.description,
          tax_id: record.pan,
          tax_registration_number: record.gstin_locations.pluck(:gstin).join(", "),
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end