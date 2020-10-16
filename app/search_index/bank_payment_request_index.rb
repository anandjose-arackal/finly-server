class BankPaymentRequestIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :policy, :status, Indexes::VpRecords::Helpers::INCLUDE_COLLABORATORS, :created_by, {payment_order: :payment_order_status}

    record_type do |record|
      'payment_tickets'
    end

    serialize do |record|
      {
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status&.id,
          status_name: record.status_name&.titleize,
          sequence_id: record.id,
          narration: record.description,
          description: record.name,
          created_by_name: record.created_by&.name,
          created_by_email: record.created_by&.email,
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end