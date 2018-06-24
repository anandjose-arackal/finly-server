class Procurements::InwardDocuments::Show < Procurements::InwardDocuments::Base
  attr_accessor :inward_document
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

  def success
    params[:inward_document] = self.inward_document
    Procurements::InwardDocuments::Show::ShowPresenter.new(user, params, messages)
  end


  class Procurements::InwardDocuments::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :inward_document

    def init
      self.inward_document = params[:inward_document]
    end
  end

end