class Procurements::PurchaseRequests::Create < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :purchase_request_params

  def init
    self.purchase_request_params = purchase_request_parameters
  end

  def validate
    unless user.is_purchase_request_initiator?
      add_message :error, 'You do not have permission for this action'
      return
    end

    # arr = self.purchase_request_params[:purchase_request_items_attributes].keys.collect {|pr| self.purchase_request_params[:purchase_request_items_attributes][pr]["department_id"].blank? }
    # if arr.include? true
    #   add_message :error, "Please select a Department for which the item would be purchased."
    #   return
    # end

    # arr  = self.purchase_request_params[:purchase_request_items_attributes].keys.collect {|pr| self.purchase_request_params[:purchase_request_items_attributes][pr]["cost_center_id"].blank? }
    # if arr.include? true
    #   add_message :error, "Please select a Cost Center for which the item would be purchased."
    #   return
    # end
    
  end

  def process
    self.purchase_request = PurchaseRequest.new(purchase_request_params)
    self.purchase_request.creator_id = user.id
    self.purchase_request.purchase_request_status_id = PurchaseRequestStatus.id_for(:draft)
    #Update purchase request line items state to :draft
    if self.purchase_request.save && self.purchase_request.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(:draft))
      pr_attachment_ids = get_attachment_ids(params)
      # line_item_attachment_ids = get_line_item_attachment_ids(params)

      Attachment.update_resource({ids: pr_attachment_ids, resource_id: self.purchase_request.id, user: user}) if pr_attachment_ids.present?
      # Update for line item attachment
      # Attachment.update_resource({ids: line_item_attachment_ids, resource_id: self.purchase_request.id, user: user}) if attachment_ids.present?
      # Update all estimated amount in the line item
      purchase_request.reload.purchase_request_items.map(&:update_estimated_amount)

      # Create document level reviewer mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.purchase_request
      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
      end
      return
    else
      add_message :error, purchase_request.errors.full_messages
      return
    end

  end

  def post_process
    add_message :success, 'Successfully created purchase request'
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Create::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Create::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end

  end

  protected
  

  # TODO - add dynamic method
  def get_attachment_ids(params)
    if params.dig(:purchase_request, :attachments_attributes).present?
      attachment_ids = []
      params.dig(:purchase_request, :attachments_attributes).each{ |k, v| attachment_ids << v[:id] }
      return attachment_ids
    end
  end

  def get_line_item_attachment_ids(params)
    if params.dig(:purchase_request, :purchase_request_items_attributes, :attachments_attributes).present?
      attachment_ids = []
      params.dig(:purchase_request, :purchase_request_items_attributes, :attachments_attributes).each{ |k, v| attachment_ids << v[:id] }
      return attachment_ids
    end
  end
end