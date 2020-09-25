class VpRecordsIndex < SearchIndex::API

  index_name 'vp_records'

  attribute :id, primary_key: true, searchable: false, displayed: false
  attribute :company_id, faceted: true, displayed: false
  attribute :record_id, searchable: false, displayed: true
  attribute :record_type, searchable: false, displayed: true
  attribute :sequence_id
  attribute :description
  attribute :line_items
  attribute :category_code
  attribute :category_name
  attribute :gl_code
  attribute :cost_center_name
  attribute :cost_center_code
  attribute :department_name
  attribute :department_code
  attribute :location_name
  attribute :location_code
  attribute :narration
  attribute :billing_location
  attribute :shipping_location
  attribute :submitted_at
  attribute :approved_at
  attribute :status_id, searchable: false, displayed: false
  attribute :status_name
  attribute :vendor_name
  attribute :vendor_sequence_id
  attribute :tax_id
  attribute :tax_registration_number
  attribute :policy_id, searchable: false, displayed: false
  attribute :policy_name
  attribute :collaborators_ids, displayed: false
  attribute :collaborators_emails
  attribute :collaborators_names

end
