class Admin::Implementations::Master::CostCenters::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.import_template'
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
    []
  end

  def post_process
  end

end
