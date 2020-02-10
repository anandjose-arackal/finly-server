class Admin::Implementations::Master::CostCenters::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.export'

  headers ({
              :id => "ID",
              :parent_id => "Parent Cost Center Name",
              :name => "Cost Center",
              :cost_center_code => "Cost Center Code",
              :destroy => "Destroy"
  })

  def valid_request

  end

  def input
    company.cost_centers.non_deleted
  end

  def id(cost_center)
    cost_center.id
  end

  def parent_id(cost_center)
   cost_center.parent&.name
  end

  def name(cost_center)
    cost_center.name
  end

  def cost_center_code(cost_center)
    cost_center.cost_center_code
  end

  def destroy(cost_center)
    ''
  end

  def post_process
  end

end
