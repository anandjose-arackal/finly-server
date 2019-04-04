class Procurements::PurchaseRequests::Destroy < Procurements::PurchaseRequests::Base

  attr_accessor :purchase_request

  def init
    id = params[:id] || params[:purchase_request_id]
    self.purchase_request = user.company.purchase_requests.find_by_id id
  end

  def authorize
    unless purchase_request.present? && (purchase_request.company_id == user.company_id)
      add_message :error, 'Unable to delete'
      return
    end
  end

  def process
    unless purchase_request.destroy
      add_message :error, "Some error occurred, unable to delete"
      return
    end
  end

  def post_process
    add_message :success, 'Purchase request deleted!'
  end


end