class Docs::P2P::PurchaseOrders::Receipts::Pending::Resolver < Resolver::API

  entity PurchaseOrder

  def load(params)
    # Todo do we show all records for admins?
    st_ids = StatusTag.where(id: StatusTag.ids_for(:receiving_shipment,:po_approved,:po_sent)).select("id").to_sql
    policies = user.company.policies.joins(:policy_user_roles).where(policy_user_roles: {user_role_id: UserRole.id_for(:goods_receiver), user_id: user.id})
    po = user.company.purchase_orders.where("policy_id in (#{policies.select('id').to_sql})")
    proc_ids = ProcurementStatusTaggable.where("procurement_id in (#{po.select("procurement_id").to_sql})").with_status_tag_ids(st_ids).select('procurement_id').to_sql
    po.where("procurement_id in (#{proc_ids})").where.not('purchase_orders.purchase_order_status_id IN (?)', PurchaseOrderStatus.ids_for([:closed, :voided]))
  end
end