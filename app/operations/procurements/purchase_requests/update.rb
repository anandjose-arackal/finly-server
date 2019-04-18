class Procurements::PurchaseRequests::Update < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_request, :purchase_request_params

  def init
    super
    self.purchase_request_params = purchase_request_parameters
  #   pr_id = params[:id] || params[:purchase_request_id]
  #   self.purchase_request = user.company.purchase_requests.find_by(id: pr_id)

  end

  def validate
    super
    # if self.purchase_request.blank?
    #   add_message :error, "Purchase Request not found for this user."
    # end

    arr = self.purchase_request_params[:purchase_request_items_attributes].keys.collect {|pr| self.purchase_request_params[:purchase_request_items_attributes][pr]["department_id"].blank? }
    if arr.include? true
      add_message :error, "Please select a Department for which the item would be purchased."
      return
    end

    arr  = self.purchase_request_params[:purchase_request_items_attributes].keys.collect {|pr| self.purchase_request_params[:purchase_request_items_attributes][pr]["cost_center_id"].blank? }
    if arr.include? true
      add_message :error, "Please select a Cost Center for which the item would be purchased."
      return
    end

  end

  def process
    self.purchase_request.assign_attributes(purchase_request_parameters)

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
    add_message :success, 'Successfully updated purchase request'
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Create::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Update::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end
  end
end