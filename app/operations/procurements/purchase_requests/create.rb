class Procurements::PurchaseRequests::Create < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :purchase_request_params, :custom_fields

  def init
    self.purchase_request_params = purchase_request_parameters
    self.custom_fields = params&.dig(:custom_fields) || params&.dig(:purchase_request, :custom_fields)
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

    # Save Custom Fields
    validate_custom_fields_pr
    return if has_errors?

    #Update purchase request line items state to :draft
    begin
      ActiveRecord::Base.transaction do
        if self.purchase_request.save && self.purchase_request.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(:draft))
          unless self.purchase_request.cost_allocation_items
            self.purchase_request.purchase_request_items.update_all(cost_center_id: self.purchase_request&.cost_center_id, department_id: self.purchase_request&.department_id)
          end
          pr_attachment_ids = get_attachment_ids(params)
          # line_item_attachment_ids = get_line_item_attachment_ids(params)

          Attachment.update_resource({ids: pr_attachment_ids, resource_id: self.purchase_request.id, user: user}) if pr_attachment_ids.present?
          # Update for line item attachment
          # Attachment.update_resource({ids: line_item_attachment_ids, resource_id: self.purchase_request.id, user: user}) if attachment_ids.present?
          # Update all estimated amount in the line item
          purchase_request.reload.purchase_request_items.map(&:update_estimated_amount)

          # Save Custom Fields
          # if params[:custom_fields].present?
          #   CustomField::SetFields.(purchase_request, FieldParentType.id_for(:purchase_request), custom_fields: params[:custom_fields], save: true, reset_fields: true)
          # end

          # Create document level reviewer mapping
          # For setting level specific reviewers from reviewal chain for a document
          params[:reviewal_document] = self.purchase_request
          document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
          unless document_reviewer_mappings_op.success?
            add_message :error, document_reviewer_mappings_op.messages[:error]
            raise
          end
          return
        else
          add_message :error, purchase_request.errors.full_messages
          return
        end
      end
    rescue => error
      debugger
      add_message :error, 'Unable to create!'
    end

  end

  def post_process
    unless has_errors?
      add_message :success, 'Successfully created purchase request'
    end
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
      params.dig(:purchase_request, :attachments_attributes).each do |item|
        if item[:id].present?
          attachment_ids << item[:id]&.to_i
        end
      end
      return attachment_ids.compact
    end
  end

  def get_line_item_attachment_ids(params)
    if params.dig(:purchase_request, :purchase_request_items_attributes, :attachments_attributes).present?
      attachment_ids = []
      params.dig(:purchase_request, :purchase_request_items_attributes, :attachments_attributes).each do |item|
        if item[:id].present?
          attachment_ids << item[:id]&.to_i
        end
      end
      return attachment_ids.compact
    end
  end
end