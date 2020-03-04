class Admin::Implementations::Master::Categories::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'categories.export'
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
    company.categories
  end

  def id(category)
    category.id
  end

  def parent_id(category)
    category.parent&.name
  end

  def gl_code(category)
    category.gl_code
  end

  def name(category)
    category.name
  end

  def active(category)
    category.active ? 'Y' : 'N'
  end

  def expense_management(category)
    category.expense_management? ? 'Y' : ''
  end

  def vendor_payments(category)
    category.vendor_payments? ? 'Y' : ''
  end

  def inward_invoice_line_items(category)
    category.inward_invoice_line_items? ? 'Y' : ''
  end

  def gst_applicable(category)
    category.gst_applicable? ? 'Y' : ''
  end

  def tds_applicable(category)
    category.tds_applicable? ? 'Y' : ''
  end

  def destroy(category)
    ''
  end

  def post_process
  end

end
