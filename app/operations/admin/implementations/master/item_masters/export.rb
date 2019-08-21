class Admin::Implementations::Master::ItemMasters::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'item_masters.export'

  headers [
              :id,
              :description,
              :category,
              :hsn_sac,
              :item_number,
              :item_expense_type,
              :po_item,
              :non_po_item,
              :discount,
              :rate,
              :destroy
          ]

  def valid_request

  end

  def input
    company.items
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
    item.item_expense_type.name
  end

  def item_number(item)
    item.item_number
  end

  def po_item(item)
    ['po_item','po_non_po_item'].include?(item.supply_item_type.name) ? 'Y' : ''
  end

  def non_po_item(item)
    ['non_po_item','po_non_po_item'].include?(item.supply_item_type.name) ? 'Y' : ''
  end

  def discount(item)
    item.rate
  end

  def rate(item)
    item.rate
  end

  def destroy(item)
    ''
  end

  def post_process
  end

end
