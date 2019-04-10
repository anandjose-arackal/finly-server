class Procurements::PurchaseRequests::IssueFromInventory < Procurements::PurchaseRequests::Base

  attr_accessor :item_ids

  def init
    self.item_ids = params[:item_ids]
  end

  def validate
    # Check item_ids should belong to company
    self.item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id = (?)", item_ids).pluck('purchase_request_items.id')
  end

  def process
    begin
      ActiveRecord::Base.transaction do
        item_ids.each do |item_id|
          # params[:document] = company.purchase_requests.joins(:purchase_request_items).where('purchase_request_items.id = ?', item_id)
          # params[:document] = PurchaseRequestItem.find_by_id item_id
          # params[:aasm_event] = 'issue_from_inventory'
          # op = WorkflowManager::Base.(user, params)
          # unless op.success?
          #   # Break and rollback if anything fails
          #   raise
          # end
          # self.workflow_output = op.workflow_output
          purchase_request_item = PurchaseRequestItem.find_by_id item_id
          purchase_request_item.status_id = PurchaseRequestItemStatus.id_for(:issued_from_inventory)
          unless purchase_request_item.save
            raise
          end
        end
      end
    rescue
      add_message :error, 'Unable to issue from inventory'
      return
    end
  end

  def post_process
    add_message :success, "Purchase request retracted"
  end
end