class Admin::Implementations::Master::ConveyanceMaster::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'conveyance_master.import_template'
  headers ({
      :id => "ID",
      :policy => "Policy",
      :distance_expense_enabled => "Distance Expense Enabled ( Y/ N )",
      :default_category => "Default Category",
      :vehicle_name => "Vehicle Name",
      :rate => "Rate"
  })

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
