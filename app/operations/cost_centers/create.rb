class CostCenters::Create < CostCenters::Base

  attr_accessor :cost_center, :cost_center_parameters

  def init
    self.cost_center_parameters = cost_center_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def pre_process
    # adding application details here
    self.cost_center_parameters[:application] = RequestStoreUtil.current_app
  end

  def process
    self.cost_center = user.company.cost_centers.build(self.cost_center_parameters)
    unless self.cost_center.save
      add_message :error, self.cost_center.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Cost center created!"
  end
end