class Procurements::RelatedDocuments < Procurements::Base
  attr_accessor :related_documents, :document, :document_type

  def pre_validate
    document_types = %w( procurement purchase_order bill_of_supply delivery_challan e_way_bill inward_document payment invoice )

    unless params[:document_type].present? && params[:document_id].present? && document_types.include?(params[:document_type])
      add_message :error, "Invalid Configuration"
    end
  end

  def init
    self.document_type = params[:document_type]
    document_id = params[:document_id]

    self.related_documents = []

    self.document = document_type.classify.constantize.find_by id: document_id
  end

  def validate
    unless document.present?
      add_message :error, "#{document_type.split('_').join(' ').titleize} not found"
    end
  end

  def process

    case document_type
    when 'purchase_order'
      invoices = {type: "Invoices"}

      documents = []

      document.invoices.each do |invoice|
      end

    end

  end
end