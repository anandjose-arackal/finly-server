class PaymentIndex < SearchIndex::Model

  index Indexes::Vp do
    include_associations({payment_order: {bank_payment_request: [:policy, :created_by]}}, :status, :reference_resource, :receiving_user_vendor)

    document_type :payments
    permissions Docs::PaymentTickets::Payments::Index.permissions
    category :transactions
    route 'orders/{{parent_id}}/params={}'
    layout(
        {
            fixed_left: [:vendor_name, :sequence_id],
            fixed_right: [:created_by_name, :created_by_email, :status_name]
        }
    )

    serialize do |record|
      if record.payment_order&.bank_payment_request.present?
        vendor = record.receiving_user_vendor
        {
            parent_id: record.payment_order&.bank_payment_request&.id,
            policy_id: record.payment_order&.bank_payment_request&.policy_id,
            policy_name: record.payment_order&.bank_payment_request&.policy&.name,
            status_id: record.status&.id,
            status_name: record.status&.name&.titleize,
            sequence_id: record.id,
            description: record.payment_order&.bank_payment_request&.description,
            narration: record.note,
            unique_transaction_references: [record.to_exposure.utr].compact,
            vendor_name: vendor&.business_name,
            vendor_trade_name: vendor&.trade_name,
            vendor_sequence_id: vendor&.vendor_id,
            created_by_name: record.payment_order&.bank_payment_request&.created_by&.name,
            created_by_email: record.payment_order&.bank_payment_request&.created_by&.email,
        }
      end
    end

    company_id do |record|
      record.company_id || record.payment_order&.bank_payment_request&.company_id
    end

  end

end