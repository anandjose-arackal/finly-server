class Docs::P2P::PurchaseOrders::Advances::Resolver < Docs::P2P::PurchaseOrders::Resolver

  entity PurchaseOrder

  def load(params)
    po = super(params)
    po.filter_all_advances.ransack(advance_amount_value_gt: 0).result(distinct: true)
  end


end