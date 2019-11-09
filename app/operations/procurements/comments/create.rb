class Procurements::Comments::Create < Procurements::Comments::Base
  attr_accessor :comment, :comment_params, :document

  def init
    self.comment_params = comment_parameters

    document_types = %w( procurement purchase_order bill_of_supply delivery_challan e_way_bill inward_document payment invoice purchase_request )

    document_type = comment_params[:parent_commentable_type]
    document_id = comment_params[:parent_commentable_id]


    if document_types.include?(document_type)
      self.document = document_type.classify.constantize.find_by id: document_id
    else
      add_message :error, 'Invalid Document Type Provided'
    end

    comment_params.delete(:parent_commentable_type)
    comment_params.delete(:parent_commentable_id)
  end

  def validate
    unless self.document.present?
      add_message :error, 'Document not found'
    end
  end

  def process
    self.comment = document.comments.new comment_params
    self.comment.user = user

    if self.comment.valid?
      self.comment.save
      add_message :success, 'Added Comment'
    end
  end

  def post_process
    # Notify users involved in comment
    case self.document.class.name
    when 'PurchaseOrder'      
      Event::EPurchaseOrder::Comment.(user, document: document, purchase_order: document)
    when 'Invoice'
      Event::EInvoice::Comment.(user, document: document, invoice: document)
    end


  end

  private

  def comment_parameters
    params.require(:comment).permit(:body, :parent_commentable_id, :parent_commentable_type)
  end
end