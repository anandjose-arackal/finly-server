class BankPaymentRequestIndex < SearchIndex::Model

  index Indexes::Vp do
    include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS, :created_by, {payment_order: :payment_order_status}

    document_type :payment_tickets
    permissions Docs::PaymentTickets::Index.permissions
    category :transactions
    route 'orders/{{record_id}}/params={}'
    layout(
        {
            fixed_left: [:description, :sequence_id],
            fixed_right: [:created_by_name, :created_by_email, :status_name]
        }
    )

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
      }.merge(Indexes::Vp::Helpers::Collaborators(record))
    end

  end

end