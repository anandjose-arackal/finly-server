class CostCenters::BulkDestroy < CostCenters::Base
  attr_accessor :cost_centers

  def init
    cost_center_ids = params[:ids] || params[:cost_center_ids]
    self.cost_centers = user.company.cost_centers.where id: cost_center_ids
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.cost_centers.blank?
      add_message :error, "No cost centers found."
      return
    end
  end


  def process
    # if self.cost_center.delete_all
    if self.cost_centers.destroy_all
      add_message :success, 'Successfully Removed Multiple Cost Centers'
    else
      add_message :error, "Couldn't remove multiple Cost Centers"
    end
  end

end
