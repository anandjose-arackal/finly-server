class Procurements::Comments::Index < Procurements::Comments::Base
  attr_accessor :comments, :document

  def init
    document_types = %w( procurement purchase_order bill_of_supply delivery_challan e_way_bill inward_document payment invoice credit_note )
    document_type = params[:document_type]
    document_id = params[:document_id]


    if document_types.include?(document_type)
      self.document = document_type.classify.constantize.find_by id: document_id
    else
      add_message :error, 'Invalid Document Type Provided'
    end
  end

  def validate
    unless self.document.present?
      add_message :error, 'Document not found'
    end
  end

  def process
    self.comments = document.comments
  end

  def success
    params[:comments] = self.comments
    Procurements::Comments::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Comments::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :comments

    def init
      self.comments = params[:comments]
    end
  end
end