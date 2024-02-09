class CostCenters::Update < CostCenters::Base

  attr_accessor :cost_center

  def init
    id = params[:id] || params[:cost_center_id]
    self.cost_center = user.company.cost_centers.non_deleted.find_by(id: id)
    self.cost_center_parameters = cost_center_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.cost_center.blank?
      add_message :error, "Cost center not found"
      return
    end
  end

  def process
    unless self.cost_center.update(self.cost_center_parameters)
      add_message :error, self.cost_center.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Cost center updated!"
  end
end