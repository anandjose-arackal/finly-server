class ExportManager::Master::Reports::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Report Export'
  configurable true
  system :vp
  screen 'report.index'
  handle :reports
  validate :input

  attribute :report_id

  def input
    result = ::ItemMaster::Item::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    items = result.inventory_line_items.includes_for_export
    items
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