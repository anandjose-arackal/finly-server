class PurchaseOrderStatusExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name do
    record.name.humanize
  end

end