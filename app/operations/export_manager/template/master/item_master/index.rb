require 'ostruct'
class ExportManager::Template::Master::ItemMaster::Index < ExportManager::Builders::Template

  label 'Export'
  description 'Item Master Export'
  export_format 'xls'
  resource 'items'
  subscribe 'items'
  default true

  attribute :item_number, template: '{{ record.item_number }}'
  attribute :gl_code, template: '{{ record.item_code }}'
  attribute :description, template: '{{ record.description }}'
  attribute :product_type, template: '{{ record.product_type }}'
  attribute :active, template: '{{ record.active }}'
  attribute :category, template: '{{ record.category.name }}'
  attribute :hsn_sac, template: '{{ record.hsn_sac }}'
  attribute :sku, template: '{{ record.sku }}'
  attribute :expense_type, template: '{{ record.expense_type }}'
  attribute :tds_applicable, template: '{{ record.tds_applicable }}'
  attribute :tax_rate, template: '{{ record.tax_rate.name }} - {{ record.tax_rate.rate }}'
  attribute :item_rate, template: '{{ record.rate }}'
  attribute :supply_item_type, template: '{{ record.scope }}'
  attribute :unit_of_measurement, template: '{{ record.unit_of_measurement }}'
  attribute :created_user, template: '{{ record.created_by.first_name }} {{ record.created_by.last_name }}'
  attribute :created_at, template: "{{ record.created_at | date: '%d-%b-%Y' }}"
end
