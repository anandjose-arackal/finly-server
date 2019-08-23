class Admin::Implementations::Master::CostCenters::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.export'

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
    company.cost_centers
  end

  def id(cost_center)
    cost_center.id
  end

  def name(cost_center)
    cost_center.name
  end

  def cost_center_code(cost_center)
    cost_center.cost_center_code
  end

  def expense_management(cost_center)
    cost_center.application == 'em' ? 'Y' : ''
  end

  def vendor_payment(cost_center)
    cost_center.application == 'vp' ? 'Y' : ''
  end

  def destroy(cost_center)
    ''
  end

  def post_process
  end

end
