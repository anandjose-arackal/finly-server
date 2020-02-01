class Procurements::Attachments::Create < Procurements::Attachments::Base
  attr_accessor :attachment_params, :attachment

  def init
    self.attachment_params = attachment_parameters
  end

  def validate
    if attachment_params[:procurement_document_id].present? && attachment_params[:procurement_document_type].present?
      case attachment_params[:procurement_document_type]
      when 'PurchaseOrder'
        document = PurchaseOrder.find_by id: attachment_params[:procurement_document_id]
        unless document&.company_id == user.company_id
          attachment_params.delete(:procurement_document_type)
          attachment_params.delete(:procurement_document_id)
        end
      when 'Invoice'
        document = Invoice.find_by id: attachment_params[:procurement_document_id]
        unless document&.company_id == user.company_id
          attachment_params.delete(:procurement_document_type)
          attachment_params.delete(:procurement_document_id)
        end
      when 'CreditNote'
        document = CreditNote.find_by id: attachment_params[:procurement_document_id]
        unless document&.company_id == user.company_id
          attachment_params.delete(:procurement_document_type)
          attachment_params.delete(:procurement_document_id)
        end
      end

    else
      attachment_params.delete(:procurement_document_type)
      attachment_params.delete(:procurement_document_id)
    end
  end

  def process
    self.attachment = user.procurement_attachments.new(attachment_params)
    self.attachment.company = user.company

    if self.attachment.save
      add_message :success, 'Upload Successful'
    else
      add_message :error, attachment.errors.full_messages
      return
    end
  end

  def success
    params[:attachment] = self.attachment
    Procurements::Attachments::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::Attachments::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachment

    def init
      self.attachment = params[:attachment]
    end
  end

  private

  def attachment_parameters
    params.require(:attachment).permit(:file, :name, :description, :procurement_document_id, :procurement_document_type)
  end
end