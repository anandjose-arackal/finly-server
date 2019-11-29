class Olap::Dimensions::Item < OlapRecord
  include Analytics::Mapper

  transaction_model ::Item
  events 'item.update', 'item.create', 'item.destroy'

  map :tax
  map :discount
  map :hsn_sac
  map :company_id
  map :sku
  map :rate
  map :description
  map :category_id
  map :note
  map :tax_rate_id
  map :is_deleted
  map :item_code
  map :account
  map :supply_item_type_id
  map :deleted_at
  map :product_type_id
  map :item_number
  map :unit_of_measurement
  map :user_id
  map :active
  map :item_expense_type_id
  map :tds_applicable

end