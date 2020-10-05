class BankPaymentRequestIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :policy, :status, Indexes::VpRecords::Helpers::INCLUDE_COLLABORATORS, :created_by

    serialize do |record|
      {
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status&.id,
          status_name: record.status&.name&.titleize,
          sequence_id: record.id,
          narration: record.description,
          description: record.name,
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end