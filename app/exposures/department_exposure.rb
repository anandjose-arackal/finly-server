class DepartmentExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :gstin, record_attribute: true
  attribute :name, record_attribute: true
  attribute :gl_code, record_attribute: true
  attribute :department_code, record_attribute: true

end