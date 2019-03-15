class Procurements::InwardDocuments::Show < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :purchase_order
  def init
    inward_document_id = params[:id] || params[:inward_document_id]
    self.inward_document = InwardDocument.find_by id: inward_document_id
  end

  def validate
    return if record_not_present
    validate_association
  end

  def process
    # get purchase order
    procurement = inward_document.procurement

    self.purchase_order = procurement.purchase_order
  end

  def success
    params[:inward_document] = self.inward_document
    params[:purchase_order] = self.purchase_order
    Procurements::InwardDocuments::Show::ShowPresenter.new(user, params, messages)
  end


  class Procurements::InwardDocuments::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :inward_document, :purchase_order

    def init
      self.inward_document = params[:inward_document]
      self.purchase_order = params[:purchase_order]
    end
  end

  def validate_presence
    if self.inward_document.blank? || (inward_document.company_id != user.company_id)
      add_message :error, 'Inward Document not found'
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_association
    return if inward_document.validate_if_admin?(user)
    return if inward_document.validate_if_owner?(user)
    return if inward_document.validate_if_manager?(user)
    # As show page is consolidated, allow user to access this  page if he is allowed to access one or all document
    return if purchase_order.validate_if_owner(user)
    return if purchase_order.validate_if_admin(user)
    return if purchase_order.validate_if_reviewer(user)
    raise_unauthorized_exception
  end

end