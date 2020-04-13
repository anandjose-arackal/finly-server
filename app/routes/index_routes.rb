IndexBuilder::Router.draw do
  # Masters
  route "vendors", Masters::Vendors::Index
  route "items", Masters::Items::Index
  route "item_master", Masters::Items::Index

  # Docs
  route "invoices", Docs::P2P::Invoices::Index
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Index
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Index
  route 'utility_bills', Docs::UtilityBills::Bills::Index
end