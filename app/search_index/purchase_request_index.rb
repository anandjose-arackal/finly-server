class PurchaseRequestIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :policy, :status, Indexes::VpRecords::Helpers::INCLUDE_COLLABORATORS, :created_by,
                         {line_items: [:delivery_location, :cost_center, :department, :item]}

    serialize do |record|
      {
          policy_id: record.policy_id,
          policy_name: record.policy&.name,
          status_id: record.status&.id,
          status_name: record.status&.name,
          sequence_id: record.order_number,
          narration: record.note,
          location_names: record.line_items.map { |line_item| line_item.delivery_location&.name },
          location_codes: record.line_items.map { |line_item| line_item.delivery_location&.location_code },
          cost_center_names: record.line_items.map { |line_item| line_item.cost_center&.name },
          cost_center_codes: record.line_items.map { |line_item| line_item.cost_center&.cost_center_code },
          department_names: record.line_items.map { |line_item| line_item.department&.name },
          department_codes: record.line_items.map { |line_item| line_item.department&.department_code },
          line_items: record.line_items.map { |line_item| line_item.item.description },
          line_item_numbers: record.line_items.map { |line_item| line_item.item.item_number },
      }.merge(Indexes::VpRecords::Helpers::Collaborators(record))
    end

  end

end