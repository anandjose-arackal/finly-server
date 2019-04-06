class Procurements::PurchaseRequests::Create < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :purchase_request_params
  def init
    self.purchase_request_params = purchase_request_parameters
  end

  def validate
    
  end

  def process
    self.purchase_request = PurchaseRequest.new(purchase_request_params)
    self.purchase_request.creator_id = user.id
    self.purchase_request.purchase_request_status_id = PurchaseRequestStatus.id_for(:draft)
    if self.purchase_request.save
      # Create document level reviewer mapping
      # For setting level  specific reviewers from reviewal chain for a document
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
end