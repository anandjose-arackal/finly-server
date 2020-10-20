class PurchaseRequestIndex < Searchkick::Api::DSL

  scope do
    includes(
        :policy, :status, :created_by,
        {line_items: [:delivery_location, :cost_center, :department, :item]}
    )
  end

  record_type 'purchase_requests'

  field :policy_id, value: -> (record) { record.policy_id }, searchable: false, displayable: false
  field :policy_name, value: -> (record) { record.policy&.name }
  field :status_id, value: -> (record) { record.status&.id }, searchable: false, displayable: false
  field :status_name, value: -> (record) { record.status&.name&.titleize }
  field :sequence_id, value: -> (record) { record.order_number }
  field :description, value: -> (record) { record.description }
  field :narration, value: -> (record) { record.note }
  field :location_names, value: -> (record) { record.line_items.map { |line_item| line_item.delivery_location&.name } }
  field :location_codes, value: -> (record) { record.line_items.map { |line_item| line_item.delivery_location&.location_code } }
  field :cost_center_names, value: -> (record) { record.line_items.map { |line_item| line_item.cost_center&.name } }
  field :cost_center_codes, value: -> (record) { record.line_items.map { |line_item| line_item.cost_center&.cost_center_code } }
  field :department_names, value: -> (record) { record.line_items.map { |line_item| line_item.department&.name } }
  field :department_codes, value: -> (record) { record.line_items.map { |line_item| line_item.department&.department_code } }
  field :line_items, value: -> (record) { record.line_items.map { |line_item| line_item.item.description } }
  field :line_item_numbers, value: -> (record) { record.line_items.map { |line_item| line_item.item.item_number } }

  # included do
  #   scope :searchkick_import, -> {
  #     includes(
  #         :policy, :status, :created_by,
  #         {line_items: [:delivery_location, :cost_center, :department, :item]}
  #     )
  #   }
  # end
  #
  # def searchkick_data
  #   {
  #       policy_id: policy_id,
  #       policy_name: policy&.name,
  #       status_id: status&.id,
  #       status_name: status&.name&.titleize,
  #       sequence_id: order_number,
  #       description: description,
  #       narration: note,
  #       location_names: line_items.map { |line_item| line_item.delivery_location&.name },
  #       location_codes: line_items.map { |line_item| line_item.delivery_location&.location_code },
  #       cost_center_names: line_items.map { |line_item| line_item.cost_center&.name },
  #       cost_center_codes: line_items.map { |line_item| line_item.cost_center&.cost_center_code },
  #       department_names: line_items.map { |line_item| line_item.department&.name },
  #       department_codes: line_items.map { |line_item| line_item.department&.department_code },
  #       line_items: line_items.map { |line_item| line_item.item.description },
  #       line_item_numbers: line_items.map { |line_item| line_item.item.item_number },
  #   }
  # end

  # index Indexes::Vp do
  #   include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS, :created_by,
  #                        {line_items: [:delivery_location, :cost_center, :department, :item]}
  #
  #   document_type :purchase_requests
  #   features [:procurement, :purchase_requisition_system]
  #   permissions Docs::P2P::PurchaseRequests::Index.permissions
  #   category :transactions
  #   route 'purchase_request/{{record_id}}/params={}'
  #   layout(
  #       {
  #           fixed_left: [:description, :sequence_id ],
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
  #         sequence_id: record.order_number,
  #         description: record.description,
  #         narration: record.note,
  #         location_names: record.line_items.map { |line_item| line_item.delivery_location&.name },
  #         location_codes: record.line_items.map { |line_item| line_item.delivery_location&.location_code },
  #         cost_center_names: record.line_items.map { |line_item| line_item.cost_center&.name },
  #         cost_center_codes: record.line_items.map { |line_item| line_item.cost_center&.cost_center_code },
  #         department_names: record.line_items.map { |line_item| line_item.department&.name },
  #         department_codes: record.line_items.map { |line_item| line_item.department&.department_code },
  #         line_items: record.line_items.map { |line_item| line_item.item.description },
  #         line_item_numbers: record.line_items.map { |line_item| line_item.item.item_number },
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end