class Procurements::PurchaseRequests::BulkDestroy < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests

  def init
    purchase_request_ids = params[:id] || params[:ids] || params[:purchase_request_ids]
    self.purchase_requests = user.purchase_requests.deleteable.with_ids(purchase_request_ids) # allow delete only for their own pr's
  end

  def validate
    if self.purchase_requests.blank?
      add_message :error, 'You need to select atleast one purchase order to delete'
      return
    end
  end


  def process
    # if self.cost_center.delete_all
    if self.purchase_requests.destroy_all
      add_message :success, 'Successfully deleted the selected Purchase Requests'
    else
      add_message :error, "Error while deleting the Purchase Requests"
    end
  end

end
