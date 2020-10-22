class PaymentIndex < Searchkick::Api::DSL

  scope do
    where.not(payment_order_id: nil)
        .where(receiving_user_type: 'YesBankVendor') #Sync only Vendor Payments
        .includes({payment_order: {bank_payment_request: [:policy, :created_by]}}, :status, :reference_resource, :receiving_user)
  end

  record_type 'payments'

  field :payment_ticket_id, value: -> (record) { record.payment_order&.bank_payment_request&.id }
  field :policy_id, value: -> (record) { record.payment_order&.bank_payment_request&.policy_id }, searchable: false, displayable: false
  field :policy_name, value: -> (record) { record.payment_order&.bank_payment_request&.policy&.name }
  field :status_id, value: -> (record) { record.status&.id }, searchable: false, displayable: false
  field :status_name, value: -> (record) { record.status&.name&.titleize }
  field :sequence_id, value: -> (record) { record.id }
  field :description, value: -> (record) { record.payment_order&.bank_payment_request&.description }
  field :narration, value: -> (record) { record.note }
  field :unique_transaction_references, value: -> (record) { [record.to_exposure.utr].compact }
  field :vendor_name, value: -> (record) { record.receiving_user&.business_name }
  field :vendor_trade_name, value: -> (record) { record.receiving_user&.trade_name }
  field :vendor_id, value: -> (record) { record.receiving_user&.vendor_id }
  field :created_by_name, value: -> (record) { record.payment_order&.bank_payment_request&.created_by&.name }
  field :created_by_email, value: -> (record) { record.payment_order&.bank_payment_request&.created_by&.email }

  def self.should_index?(record)
    record.deleted_at.nil? and
        record.company_id.present? and
        record.payment_order.present? and
        record.payment_order.bank_payment_request.present? and
        record.receiving_user_type == 'YesBankVendor' #Sync only Vendor Payments
  end

  # included do
  #   scope :searchkick_import, -> {
  #     includes({payment_order: {bank_payment_request: [:policy, :created_by]}}, :status, :reference_resource, :receiving_user_vendor)
  #   }
  # end
  #
  # def searchkick_data
  #   {
  #       payment_ticket_id: payment_order&.bank_payment_request&.id,
  #       policy_id: payment_order&.bank_payment_request&.policy_id,
  #       policy_name: payment_order&.bank_payment_request&.policy&.name,
  #       status_id: status&.id,
  #       status_name: status&.name&.titleize,
  #       sequence_id: id,
  #       description: payment_order&.bank_payment_request&.description,
  #       narration: note,
  #       unique_transaction_references: [to_exposure.utr].compact,
  #       vendor_name: receiving_user_vendor&.business_name,
  #       vendor_trade_name: receiving_user_vendor&.trade_name,
  #       vendor_id: receiving_user_vendor&.vendor_id,
  #       created_by_name: payment_order&.bank_payment_request&.created_by&.name,
  #       created_by_email: payment_order&.bank_payment_request&.created_by&.email,
  #   }
  # end
  #
  # def should_index?
  #   deleted_at.nil? and company_id.present?
  # end

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