class PaymentIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations({payment_order: {bank_payment_request: :policy}}, :status)

    serialize do |record|
      {
          policy_id: record.payment_order&.bank_payment_request&.policy_id,
          policy_name: record.payment_order&.bank_payment_request&.policy&.name,
          status_id: record.status&.id,
          status_name: record.status&.name,
          sequence_id: record.id,
          description: record.payment_order&.bank_payment_request&.description,
          narration: record.note,
          unique_transaction_references: ([record.to_exposure.utr] if record.reference_resource.present?)
      }
    end

    company_id do |record|
      record.company_id || record.payment_order&.bank_payment_request&.company_id
    end

  end

end