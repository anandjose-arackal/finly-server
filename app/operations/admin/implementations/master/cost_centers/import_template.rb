class Admin::Implementations::Master::CostCenters::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.import_template'
  headers [
              :id,
              :name,
              :cost_center_code,
              :expense_management,
              :vendor_payment,
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
