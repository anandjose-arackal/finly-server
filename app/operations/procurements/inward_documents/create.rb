class Procurements::InwardDocuments::Create < Procurements::InwardDocumentItems::Base
  attr_accessor :inward_document
  def init
    self.inward_document_params = inward_document_parameters
  end

  def validate

  end

  def process

  end
end