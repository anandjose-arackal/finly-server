class Procurements::PurchaseRequests::PurchaseRequestItems::Base < BaseOperation
  attr_accessor :workflow_output, :company, :purchase_request, :purchase_request_item


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def init
    self.company = user.company
    id  = params[:id] || params[:purchase_request_item_id]
    # self.purchase_request = Procurements::PurchaseRequests::Show.(current_user, params).purchase_request
    self.purchase_request_item = user.company.purchase_requests.joins(:purchase_request_items).where('purchase_request_items.id = ?', id)
  end

  def validate
    if purchase_request_item.blank?
      add_message :error, 'Purchase request item not found'
    end
  end

end