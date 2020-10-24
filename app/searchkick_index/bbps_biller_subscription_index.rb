class BbpsBillerSubscriptionIndex < Searchkick::Api::DSL

  scope do
    includes(:policy, :status, :created_by, :location, :department, :cost_center, :biller)
  end

  record_type 'utility_subscriptions'

  field :vendor_name, value: -> (record) { record.biller.biller_name }
  field :policy_id, value: -> (record) { record.policy_id }, searchable: false
  field :policy_name, value: -> (record) { record.policy&.name }
  field :status_id, value: -> (record) { record.status_id }, searchable: false
  field :status_name, value: -> (record) { record.status&.name&.titleize }
  field :sequence_id, value: -> (record) { record.sequence_id }
  field :description, value: -> (record) { record.name }
  field :narration, value: -> (record) { record.note }
  field :category_name, value: -> (record) { record.biller.biller_category_name }
  field :location_names, value: -> (record) { [record.location&.name] }
  field :location_codes, value: -> (record) { [record.location&.location_code] }
  field :department_names, value: -> (record) { [record.department&.name] }
  field :department_codes, value: -> (record) { [record.department&.department_code] }
  field :cost_center_names, value: -> (record) { [record.cost_center&.name] }
  field :cost_center_codes, value: -> (record) { [record.cost_center&.cost_center_code] }

  # included do
  #   scope :searchkick_import, -> {
  #     includes(:policy, :status, :created_by, :location, :department, :cost_center, :biller)
  #   }
  #
  #   searchkick_record_type :utility_subscriptions
  # end
  #
  # def searchkick_data
  #   {
  #       vendor_name: biller.biller_name,
  #       policy_id: policy_id,
  #       policy_name: policy&.name,
  #       status_id: status_id,
  #       status_name: status&.name&.titleize,
  #       sequence_id: sequence_id,
  #       description: name,
  #       narration: note,
  #       category_name: biller.biller_category_name,
  #       location_names: [location&.name],
  #       location_codes: [location&.location_code],
  #       department_names: [department&.name],
  #       department_codes: [department&.department_code],
  #       cost_center_names: [cost_center&.name],
  #       cost_center_codes: [cost_center&.cost_center_code]
  #   }
  # end

  # index Indexes::Vp do
  #   include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS,
  #                        :created_by, :location, :department, :cost_center, :biller
  #
  #   document_type :utility_subscriptions
  #   features :utility_bills_enabled
  #   permissions Docs::UtilityBills::Subscriptions::Index.permissions
  #   category :masters
  #   route 'utility_bill_master/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:description, :sequence_id, :vendor_name],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         vendor_name: record.biller.biller_name,
  #         policy_id: record.policy_id,
  #         policy_name: record.policy&.name,
  #         status_id: record.status_id,
  #         status_name: record.status&.name&.titleize,
  #         sequence_id: record.sequence_id,
  #         description: record.name,
  #         narration: record.note,
  #         category_name: record.biller.biller_category_name,
  #         location_names: [record.location&.name],
  #         location_codes: [record.location&.location_code],
  #         department_names: [record.department&.name],
  #         department_codes: [record.department&.department_code],
  #         cost_center_names: [record.cost_center&.name],
  #         cost_center_codes: [record.cost_center&.cost_center_code]
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end