class Docs::P2P::Invoices::Contracts::Update < Reform::Form

  property :erp_sync_status_id, deserializer: -> (input, represented, **) {
    if input[:erp_sync_status].present?
      represented.erp_sync_status_id = ErpSyncStatus.id_for(input[:erp_sync_status])
    end
  }
  property :erp_sync_message
  property :erp_sync_reference_id

end