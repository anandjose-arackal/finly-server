class Dashboard::P2P::PurchaseRequests < Dashboard::IndexCard

  index_route 'purchase_requests'
  path 'purchase_requests'
  created_by :creator_id
  scope_status PurchaseRequestStatus.id_for(:awaiting_approval),
               PurchaseRequestStatus::GROUP_APPROVED,
               PurchaseRequestStatus.id_for(:closed)

end