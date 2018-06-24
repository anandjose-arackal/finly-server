class Procurements::InwardDocuments::Show < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :purchase_order
  def init
    inward_document_id = params[:id] || params[:inward_document_id]
    self.inward_document = InwardDocument.find_by id: inward_document_id
  end

  def validate
    unless self.inward_document.present?
      add_message :error, 'Inward Document not found'
      return
    end
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

end