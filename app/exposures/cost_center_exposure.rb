class CostCenterExposure < Exposures::API

  attribute :id
  attribute :name, record_attribute: true
  attribute :cost_center_code, record_attribute: true
  attribute :gl_code, record_attribute: true

end