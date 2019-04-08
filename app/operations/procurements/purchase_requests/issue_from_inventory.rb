class Procurements::PurchaseRequests::IssueFromInventory < Procurements::PurchaseRequests::Base

  attr_accessor :item_ids

  def init
    self.item_ids = params[:item_ids]
  end

  def process
    begin
      ActiveRecord::Base.transaction do
        item_ids.each do |item_id|
          # params[:document] = company.purchase_requests.joins(:purchase_request_items).where('purchase_request_items.id = ?', item_id)
          params[:document] = PurchaseRequestItem.find_by_id item_id
          params[:aasm_event] = 'issue_from_inventory'

          op = WorkflowManager::Base.(user, params)
          unless op.success?
            # Break and rollback if anything fails
            raise
          end
          # self.workflow_output = op.workflow_output
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