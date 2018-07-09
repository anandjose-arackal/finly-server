class Procurements::Mailers::Base < BaseOperation
  attr_accessor :mailer_params, :email_options, :document

  def init
    document_types = %w( purchase_order bill_of_supply delivery_challan e_way_bill inward_document payment invoice )
    document_type = comment_params[:document_type]
    document_id = comment_params[:document_id]

    if document_types.include?(document_type)
      self.document = document_type.classify.constantize.find_by id: document_id
    else
      add_message :error, 'Invalid Document Type Provided'
      return
    end

    self.email_options = {}
    self.email_options[:email_to] = params[:email_to]
    self.email_options[:email_bcc_to] = params[:email_bcc_to]

    self.email_subject[:email_subject] = params[:email_subject]
    self.email_body[:email_body] = params[:email_body]
  end

  def validate
    unless self.document.present?
      add_message :error, 'Document not found'
    end

    if self.email_options[:email_to].blank?
      add_message :error, 'Email ID is blank. Please Provide an Email ID'
    end

    if self.email_options[:email_subject].blank? && email_options[:email_body].blank?
      add_message :error, "Both email subject and body can't be blank"
    end
  end

  def process
    ProcurementMailer.delay.send_mail(purchase_order, email_options)
  end

  def success
    params[:mailer] = mailer
    Procurements::Mailers::Base::MailerPresenter.new(user, params, messages)
  end

  class Procurements::Mailers::Base::MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :mailer

    def init
    end
  end
end