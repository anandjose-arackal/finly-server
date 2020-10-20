class BbpsBillIndex < Searchkick::Api::DSL

  scope do
    includes(:policy, :status, {subscription: :biller}, :payments, :created_by, :cost_center, :location, :department)
  end

  record_type 'utility_bills'

  field :policy_id, value: ->(record) { record.policy_id }, displayable: false, searchable: false
  field :policy_name, value: ->(record) { record.policy&.name }
  field :status_id, value: ->(record) { record.status&.id }, displayable: false, searchable: false
  field :status_name, value: ->(record) { record.status&.name&.titleize }
  field :sequence_id, value: ->(record) { record.sequence_id }
  field :narration, value: ->(record) { record.note }
  field :invoice_number, value: ->(record) { record.bill_number }
  field :vendor_id, value: ->(record) { record.subscription.sequence_id }
  field :vendor_name, value: ->(record) { record.subscription.biller.biller_name }
  field :category_name, value: ->(record) { record.subscription.biller.biller_category_name }
  field :description, value: ->(record) { record.subscription.name }
  field :cost_center_names, value: ->(record) { [record.cost_center&.name] }
  field :cost_center_codes, value: ->(record) { [record.cost_center&.cost_center_code] }
  field :department_names, value: ->(record) { [record.department&.name] }
  field :department_codes, value: ->(record) { [record.department&.department_code] }
  field :location_names, value: ->(record) { [record.location&.name] }
  field :location_codes, value: ->(record) { [record.location&.location_code] }
  field :unique_transaction_references, value: ->(record) { [record.payments&.first&.bbps_bank_transaction&.bbps_ref_id] }

  # included do
  #   scope :searchkick_import, -> {
  #     includes(:policy, :status, {subscription: :biller}, :payments, :created_by)
  #   }
  #
  #   searchkick_record_type :utility_bills
  # end
  #
  # def searchkick_data
  #   {
  #       policy_id: policy_id,
  #       policy_name: policy&.name,
  #       status_id: status&.id,
  #       status_name: status&.name&.titleize,
  #       sequence_id: sequence_id,
  #       narration: note,
  #       invoice_number: bill_number,
  #       vendor_id: subscription.sequence_id,
  #       vendor_name: subscription.biller.biller_name,
  #       category_name: subscription.biller.biller_category_name,
  #       description: subscription.name,
  #       cost_center_names: [cost_center&.name],
  #       cost_center_codes: [cost_center&.cost_center_code],
  #       department_names: [department&.name],
  #       department_codes: [department&.department_code],
  #       location_names: [location&.name],
  #       location_codes: [location&.location_code],
  #       unique_transaction_references: [payments&.first&.bbps_bank_transaction&.bbps_ref_id]
  #   }
  # end

  # index Indexes::Vp do
  #   include_associations(:policy, :status, {subscription: :biller}, :payments, :created_by)
  #
  #   document_type :utility_bills
  #   features [:procurement]
  #   permissions Docs::UtilityBills::Subscriptions::Index.permissions
  #   category :transactions
  #   route 'utility_bill/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:vendor_name, :sequence_id],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         policy_id: record.policy_id,
  #         policy_name: record.policy&.name,
  #         status_id: record.status&.id,
  #         status_name: record.status&.name&.titleize,
  #         sequence_id: record.sequence_id,
  #         narration: record.note,
  #         invoice_number: record.bill_number,
  #         vendor_id: record.subscription.sequence_id,
  #         vendor_name: record.subscription.biller.biller_name,
  #         category_name: record.subscription.biller.biller_category_name,
  #         description: record.subscription.name,
  #         cost_center_names: [record.cost_center&.name],
  #         cost_center_codes: [record.cost_center&.cost_center_code],
  #         department_names: [record.department&.name],
  #         department_codes: [record.department&.department_code],
  #         location_names: [record.location&.name],
  #         location_codes: [record.location&.location_code],
  #         unique_transaction_references: [record.payments&.first&.bbps_bank_transaction&.bbps_ref_id]
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end