class Admin::Implementations::Master::ItemMasters::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'item_masters.export'

  headers ({
      :id => "ID",
      :description => "Description (mandatory)",
      :category => "Category Name",
      :hsn_sac => "HSN - SAC",
      :item_number => "Item Code",
      :item_expense_type => "Expense Type",
      :po_item =>  "PO Item (Y/N)",
      :non_po_item => "Non PO Item (Y/N)",
      :good_service => "Goods or Service ( G / S)",
      :tds_applicable => "TDS Applicable (Y/N)",
      :discount => "Discount",
      :rate => "Rate",
      :destroy => "Destroy"
  })
  def valid_request

  end

  def input
    company.items.non_deleted.includes(:category,:item_expense_type,:supply_item_type)
  end

  def id(item)
    item.id
  end

  def description(item)
    item.description
  end

  def category(item)
    item.category&.name rescue ''
  end

  def hsn_sac(item)
    item.hsn_sac
  end

  def item_expense_type(item)
    item.item_expense_type&.name
  end

  def item_number(item)
    item.item_number
  end

  def po_item(item)
    ['po_item','po_non_po_item'].include?(item.supply_item_type&.name) ? 'Y' : ''
  end

  def non_po_item(item)
    ['non_po_item','po_non_po_item'].include?(item.supply_item_type&.name) ? 'Y' : ''
  end

  def discount(item)
    item.rate
  end

  def good_service(item)
    item.product_type&.name&.humanize rescue ''
  end

  def rate(item)
    item.rate
  end

  def tds_applicable(item)
    (item.tds_applicable? ? 'Y' : 'N')
  end

  def destroy(item)
    ''
  end

  def post_process
  end

end
