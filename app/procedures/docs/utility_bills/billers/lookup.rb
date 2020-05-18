class Docs::UtilityBills::Billers::Lookup < Lookup::API

  resolver 'bbps_billers.default'
  search_key :biller_id_or_biller_name_or_biller_category_name_or_biller_alias_name_cont

  attribute :id, visible: false
  attribute :biller_id
  attribute :name, value: :biller_name
  attribute :biller_category_name

end