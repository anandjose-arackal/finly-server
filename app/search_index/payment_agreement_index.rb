class PaymentAgreementIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :policy, :status, :created_by, Indexes::VpRecords::Helpers::INCLUDE_COLLABORATORS

    serialize do |record|
      {
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status&.id,
          status_name: record.status&.name&.titleize,
          sequence_id: record.order_number,
          description: record.title,
          narration: record.note,
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end