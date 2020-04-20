class Docs::P2P::PurchaseOrders::Advances::Index < Docs::P2P::PurchaseOrders::Index
  include DynamicAttributes

  resolver 'purchase_orders.advances'
  reference '{{record.id}}', procurement_id: '{{record.procurement_id}}', procurement_type: 'po'
  custom_fields :purchase_order

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :advance_amount_status_id_eq
    counts = collection.group(:advance_amount_status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)

    AdvanceAmountStatus.values.each do |status|
      counter.add AdvanceAmountStatus.id_for(status), status.to_s.titleize, counts[AdvanceAmountStatus.id_for(status)].to_i
    end

    counter
  end

end