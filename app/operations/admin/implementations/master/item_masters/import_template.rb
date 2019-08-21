class Admin::Implementations::Master::ItemMasters::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'item_masters.import_template'
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
    []
  end

  def post_process
  end

end
