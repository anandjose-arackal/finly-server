class Admin::Implementations::Master::ConveyanceMaster::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'conveyance_master.import'
  headers ({
      :id => "ID",
      :policy => "Policy",
      :distance_expense_enabled => "Distance Expense Enabled ( Y/ N )",
      :default_category => "Default Category",
      :vehicle_name => "Vehicle Name",
      :rate => "Rate"
  })

  attr_accessor :distance_expense_params, :policy

  def create_record(data)
    distance_expense_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end
    distance_expense_config = self.policy.distance_expense_config
    distance_expense_config.enabled = distance_expense_params[:enabled]
    distance_expense_config.default_category_id = distance_expense_params[:default_category]
    distance_expense_config.enforce_category = true if distance_expense_params[:default_category].present?
    policy.vehicle_rates.create(vehicle_name: distance_expense_params[:name], distance_unit_id: PhysicalUnit.first.id, :rate_attributes=> { currency_id: 1, value: distance_expense_params[:rate]})

    unless distance_expense_config.save
      return result false, distance_expense_config.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def set_params(data)
    messages = []
    policy_name= data[:policy]&.to_s
    enabled = data[:distance_expense_enabled]&.to_s.upcase == 'Y' ? true : false
    default_category = nil
    if data[:default_category].present?
      default_category= company.categories.find_by_name data[:default_category]
      messages <<  "Category Not found" if default_category.blank?
    end

    if policy_name.present?
      self.policy = company.policies.with_application("em").find_by_name(policy_name)
      messages <<  "Policy Not found" if self.policy.blank?
    end

    name = data[:vehicle_name].to_s
    if name.blank?
      messages << "Name cant be blank"
    end

    rate = data[:rate].to_f
    if rate.blank?
      messages << "Rate cant be blank"
    end
    
    params = {
        name: name,
        rate: rate,
        enabled: enabled,
        default_category: default_category&.id
    }
    [params,messages]
  end
end
