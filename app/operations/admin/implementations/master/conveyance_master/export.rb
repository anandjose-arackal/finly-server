class Admin::Implementations::Master::ConveyanceMaster::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'conveyance_master.export'
  headers ({
      :id => "ID",
      :policy => "Policy",
      :distance_expense_enabled => "Distance Expense Enabled ( Y/ N )",
      :default_category => "Default Category",
      :vehicle_name => "Vehicle Name",
      :rate => "Rate",
      :destroy => "Destroy"
  })

  def valid_request

  end

  def input
    policy_ids  = company.policies.pluck(:id)
    VehicleRate.where(policy_id: policy_ids).includes(:rate,policy: {distance_expense_config: :default_category}).reorder(policy_id: :asc).non_deleted
  end

  def id(vehicle_rate)
    vehicle_rate.id
  end

  def policy(vehicle_rate)
    vehicle_rate.policy&.name
  end

  def distance_expense_enabled(vehicle_rate)
    (vehicle_rate.policy.distance_expense_config&.enabled? ? 'Y' : 'N')  rescue ''
  end

  def default_category(vehicle_rate)
    vehicle_rate.policy.distance_expense_config&.default_category&.name rescue ''
  end

  def vehicle_name(vehicle_rate)
    vehicle_rate.vehicle_name
  end

  def rate(vehicle_rate)
    vehicle_rate.rate&.value&.to_f rescue ''
  end

  def destroy(vehicle_rate)
    ''
  end


end