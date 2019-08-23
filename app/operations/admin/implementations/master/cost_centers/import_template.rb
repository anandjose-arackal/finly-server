class Admin::Implementations::Master::CostCenters::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.import_template'
  headers ({
      :id => "ID",
      :name => "Cost Center",
      :cost_center_code => "Cost Center Code",
      :expense_management => "Expense Management (Y)",
      :vendor_payment => "Vendor Payments (Y)",
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
