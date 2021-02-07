require 'ostruct'
class ExportManager::Master::ItemMaster::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Item Master Export'
  configurable true
  system :vp
  screen 'item_master.index'
  handle :inventory_items

  has_template true

  attribute :item_number
  attribute :gl_code
  attribute :description
  attribute :product_type
  attribute :active
  attribute :category
  attribute :hsn_sac
  attribute :sku
  attribute :expense_type
  attribute :tds_applicable
  attribute :tax_rate
  attribute :item_rate
  attribute :supply_item_type
  attribute :unit_of_measurement
  attribute :created_user
  attribute :created_at

  def input
    resolve('items.default').includes_for_export
  end

  def item_number(item)
    item.item_number
  end

  def gl_code(item)
    item.item_code
  end

  def description(item)
    item.description
  end

  def product_type(item)
    item.product_type&.name&.humanize
  end

  def active(item)
    item.active
  end

  def category(item)
    item.category&.name
  end

  def hsn_sac(item)
    item.hsn_sac
  end

  def sku(item)
    item.sku
  end

  def unit_of_measurement(item)
    item.unit_of_measurement
  end

  def expense_type(item)
    item.item_expense_type&.name&.humanize
  end

  def tds_applicable(item)
    item.tds_applicable
  end

  def tax_rate(item)
    "#{item.tax_rate&.name} - #{item.tax_rate&.rate}"
  end

  def item_rate(item)
    item.rate
  end

  def supply_item_type(item)
    item.supply_item_type&.name&.humanize
  end

  def created_user(item)
    "#{item.user&.first_name} #{item.user&.last_name}"
  end

  def created_at(item)
    item.created_at&.strftime('%d-%b-%Y')
  end


end
