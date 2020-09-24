class RecordsIndex < SearchIndex::API

  index_name 'records'

  attribute :record_id, primary_key: true, searchable: false
  attribute :record_type
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
  attribute :status_id, faceted: true, searchable: false, displayed: false
  attribute :status_name
  attribute :vendor_name
  attribute :vendor_sequence_id
  attribute :tax_id
  attribute :tax_registration_number
  attribute :policy_id, faceted: true, searchable: false, displayed: false
  attribute :policy_name
  attribute :collaborators_ids, faceted: true, searchable: false, displayed: false
  attribute :collaborators_emails
  attribute :collaborators_names
  attribute :initiator_ids, faceted: true, searchable: false, displayed: false
  attribute :initiator_name
  attribute :initiator_email

end
