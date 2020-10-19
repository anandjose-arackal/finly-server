module PurchaseOrderIndex
  extend ActiveSupport::Concern

  included do
    scope :searchkick_import, -> {
      includes(
          :policy, :status, :created_by,
          :location, :delivery_location, :vendor,
          {line_items: [:cost_center, :department, :inventory_line_item]}
      )
    }
  end

  def searchkick_data
    {
        parent_id: procurement_id,
        parent_type: 'po',
        policy_id: policy_id,
        policy_name: policy&.name,
        status_id: status&.id,
        status_name: status&.name&.titleize,
        po_number: purchase_order_number,
        cost_center_names: line_items.map { |line_item| line_item.cost_center&.name },
        cost_center_codes: line_items.map { |line_item| line_item.cost_center&.cost_center_code },
        department_names: line_items.map { |line_item| line_item.department&.name },
        department_codes: line_items.map { |line_item| line_item.department&.department_code },
        line_items: line_items.pluck(:description),
        line_item_numbers: line_items.map { |line_item| line_item.inventory_line_item&.item_number },
        billing_location_name: location&.name,
        billing_location_code: location&.location_code,
        shipping_location_name: delivery_location&.name,
        shipping_location_code: delivery_location&.location_code,
        vendor_name: vendor&.business_name,
        vendor_trade_name: vendor&.trade_name,
        vendor_id: vendor&.vendor_id,
    }
  end

  # index Indexes::Vp do
  #   include_associations :policy, :status, Indexes::Vp::Helpers::INCLUDE_COLLABORATORS, :created_by,
  #                        :location, :delivery_location, :vendor,
  #                        {line_items: [:cost_center, :department, :inventory_line_item]}
  #
  #   document_type :purchase_orders
  #   features [:procurement]
  #   permissions Docs::P2P::PurchaseOrders::Index.permissions
  #   category :transactions
  #   route 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}'
  #   layout(
  #       {
  #           fixed_left: [:vendor_name, :sequence_id],
  #           fixed_right: [:created_by_name, :created_by_email, :status_name]
  #       }
  #   )
  #
  #   serialize do |record|
  #     {
  #         parent_id: record.procurement_id,
  #         parent_type: 'po',
  #         policy_id: record.policy_id,
  #         policy_name: record.policy&.name,
  #         status_id: record.status&.id,
  #         status_name: record.status&.name&.titleize,
  #         sequence_id: record.purchase_order_number,
  #         cost_center_names: record.line_items.map { |line_item| line_item.cost_center&.name },
  #         cost_center_codes: record.line_items.map { |line_item| line_item.cost_center&.cost_center_code },
  #         department_names: record.line_items.map { |line_item| line_item.department&.name },
  #         department_codes: record.line_items.map { |line_item| line_item.department&.department_code },
  #         line_items: record.line_items.pluck(:description),
  #         line_item_numbers: record.line_items.map { |line_item| line_item.inventory_line_item&.item_number },
  #         billing_location_name: record.location&.name,
  #         billing_location_code: record.location&.location_code,
  #         shipping_location_name: record.delivery_location&.name,
  #         shipping_location_code: record.delivery_location&.location_code,
  #         vendor_name: record.vendor&.business_name,
  #         vendor_trade_name: record.vendor&.trade_name,
  #         vendor_sequence_id: record.vendor&.vendor_id,
  #     }.merge(Indexes::Vp::Helpers::Collaborators(record))
  #   end
  #
  # end

end