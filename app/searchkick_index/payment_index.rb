module PaymentIndex
  extend ActiveSupport::Concern

  included do
    scope :searchkick_import, -> {
      includes({payment_order: {bank_payment_request: [:policy, :created_by]}}, :status, :reference_resource, :receiving_user_vendor)
    }
  end

  def searchkick_data
    {
        payment_ticket_id: payment_order&.bank_payment_request&.id,
        policy_id: payment_order&.bank_payment_request&.policy_id,
        policy_name: payment_order&.bank_payment_request&.policy&.name,
        status_id: status&.id,
        status_name: status&.name&.titleize,
        payment_id: id,
        description: payment_order&.bank_payment_request&.description,
        narration: note,
        unique_transaction_references: [to_exposure.utr].compact,
        vendor_name: receiving_user_vendor&.business_name,
        vendor_trade_name: receiving_user_vendor&.trade_name,
        vendor_id: receiving_user_vendor&.vendor_id,
        created_by_name: payment_order&.bank_payment_request&.created_by&.name,
        created_by_email: payment_order&.bank_payment_request&.created_by&.email,
    }
  end

  # index Indexes::Vp do
  #   include_associations({payment_order: {bank_payment_request: [:policy, :created_by]}}, :status, :reference_resource, :receiving_user_vendor)
  #
  #   document_type :payments
  #   permissions Docs::PaymentTickets::Payments::Index.permissions
  #   category :transactions
  #   route 'orders/{{parent_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:vendor_name, :sequence_id],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     if record.payment_order&.bank_payment_request.present?
  #       vendor = record.receiving_user_vendor
  #       {
  #           parent_id: record.payment_order&.bank_payment_request&.id,
  #           policy_id: record.payment_order&.bank_payment_request&.policy_id,
  #           policy_name: record.payment_order&.bank_payment_request&.policy&.name,
  #           status_id: record.status&.id,
  #           status_name: record.status&.name&.titleize,
  #           sequence_id: record.id,
  #           description: record.payment_order&.bank_payment_request&.description,
  #           narration: record.note,
  #           unique_transaction_references: [record.to_exposure.utr].compact,
  #           vendor_name: vendor&.business_name,
  #           vendor_trade_name: vendor&.trade_name,
  #           vendor_sequence_id: vendor&.vendor_id,
  #           created_by_name: record.payment_order&.bank_payment_request&.created_by&.name,
  #           created_by_email: record.payment_order&.bank_payment_request&.created_by&.email,
  #       }
  #     end
  #   end
  #
  #   company_id do |record|
  #     record.company_id || record.payment_order&.bank_payment_request&.company_id
  #   end
  #
  # end

end