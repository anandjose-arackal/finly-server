class Admin::Implementations::Master::Categories::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.import_template'
  headers ({
      :id => "ID",
      :parent_id => "Parent Category Name",
      :gl_code => "GL CODE",
      :name => "Category Name",
      :active => 'Active (Blank or Y for active / N for deactivate)',
      :expense_management =>"Expense Management (Y for Enable",
      :vendor_payments =>"Vendor Payment (Y for Enable)",
      :inward_invoice_line_items => "Inward Invoice Line Item (Y for Enable)",
      :gst_applicable => "GST Applicable (Y for Enable)",
      :tds_applicable => "TDS Applicable (Y for Enable)",
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
