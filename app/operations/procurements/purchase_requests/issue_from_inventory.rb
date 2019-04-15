class Procurements::PurchaseRequests::IssueFromInventory < Procurements::PurchaseRequests::Base

  attr_accessor :item_ids

  def init
    self.item_ids = params[:item_ids]
  end

  def validate
    # Check item_ids should belong to company
    self.item_ids = user.company.purchase_requests.joins(:purchase_request_items).where("purchase_request_items.id IN (?)", item_ids).pluck('purchase_request_items.id')
    if item_ids.blank?
      add_message :error, 'No item to issue'
    end
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
          # If all PR items are issued from inventory/rejected, close the PR
          close_purchase_request(item_id)
        end
      end
    rescue
      add_message :error, 'Unable to issue from inventory'
      return
    end
  end

  def post_process
    add_message :success, "Successfully issued from inventory"
  end

  protected

  def close_purchase_request(item_id)
    purchase_request = PurchaseRequestItem.find_by(id: item_id).purchase_request
    # Check if all statuses are issued from inventory or approved
    # if purchase_request.purchase_request_items.pluck(:status_id).uniq.sum == [PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:rejected)].sum
    if purchase_request.purchase_request_items.where.not(status_id: [PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.id_for(:rejected)]).blank?
      params[:document] = purchase_request
      params[:aasm_event] = 'close'
      op = WorkflowManager::Base.(user, params)
      unless op.success?
        # Break and rollback if anything fails
        raise
      end
      self.workflow_output = op.workflow_output
    end
  end
end