class UserExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :first_name, record_attribute: true
  attribute :last_name, record_attribute: true
  attribute :email, record_attribute: true
  attribute :mobile_number, record_attribute: true
  attribute :location, record_attribute: true, exposure: true
  attribute :department, record_attribute: true, exposure: true
  attribute :cost_center, record_attribute: true, exposure: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :last_activity_at, record_attribute: true
  attribute :profile, record_attribute: true, exposure: true

end
