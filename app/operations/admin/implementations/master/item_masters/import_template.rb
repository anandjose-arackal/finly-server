class Admin::Implementations::Master::ItemMasters::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'item_masters.import_template'
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
    []
  end

  def post_process
  end

end
