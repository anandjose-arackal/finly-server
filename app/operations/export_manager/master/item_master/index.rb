require 'ostruct'
class ExportManager::Master::ItemMaster::Index < ExportManager::Builders::Template

  label 'Export'
  description 'Item Master Export'
  export_format 'csv'
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

  # def input
  #   resolve('items.default').includes_for_export
  # end

  # def item_number(item)
  #   item.item_number
  # end

  # def gl_code(item)
  #   item.item_code
  # end

  # def description(item)
  #   item.description
  # end

  # def product_type(item)
  #   item.product_type&.name&.humanize
  # end

  # def active(item)
  #   item.active
  # end

  # def category(item)
  #   item.category&.name
  # end

  # def hsn_sac(item)
  #   item.hsn_sac
  # end

  # def sku(item)
  #   item.sku
  # end

  # def unit_of_measurement(item)
  #   item.unit_of_measurement
  # end

  # def expense_type(item)
  #   item.item_expense_type&.name&.humanize
  # end

  # def tds_applicable(item)
  #   item.tds_applicable
  # end

  # def tax_rate(item)
  #   "#{item.tax_rate&.name} - #{item.tax_rate&.rate}"
  # end

  # def item_rate(item)
  #   item.rate
  # end

  # def supply_item_type(item)
  #   item.supply_item_type&.name&.humanize
  # end

  # def created_user(item)
  #   "#{item.user&.first_name} #{item.user&.last_name}"
  # end

  # def created_at(item)
  #   item.created_at&.strftime('%d-%b-%Y')
  # end


end