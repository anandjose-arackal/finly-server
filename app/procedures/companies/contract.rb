# This contract validates system and custom MasterSchema's
class Companies::Contract < Reform::Form

  property :name, validates: { presence: true }
  property :active, default: true
  property :configuration, populate_if_empty: CompanyConfiguration do
    property :legal_entity_name
    property :logo
    property :start_date
    property :end_date
  end

end