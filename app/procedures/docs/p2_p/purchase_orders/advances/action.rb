class Docs::P2P::PurchaseOrders::Advances::Action < ActionManager::API

  scope policy: Docs::P2P::PurchaseOrders::Policy, model: PurchaseOrder do

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "purchase_orders.index",
           authorize: :export?

  end

end