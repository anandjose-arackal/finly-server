class Procurements::Mailers::Base < BaseOperation
  attr_accessor :mailer_params, :email_options, :document, :attachments

  def init
    document_types = %w( purchase_order bill_of_supply delivery_challan e_way_bill inward_document payment invoice )
    document_type = params[:document_type]
    document_id = params[:document_id]

    if document_types.include?(document_type)
      self.document = document_type.classify.constantize.find_by id: document_id
    else
      add_message :error, 'Invalid Document Type Provided'
      return
    end

    self.email_options = {}
    self.email_options[:email_to] = params[:email_to]
    self.email_options[:email_bcc_to] = params[:email_bcc_to]

    self.email_options[:email_subject] = params[:subject]
    self.email_options[:email_body] = params[:body]
    if params[:attachments].present?
      self.attachments = self.document.attachments.with_id(params[:attachments])
    end
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
    params[:document] = self.document
    params[:email_options] = self.email_options
    params[:attachments] = self.attachments
    op = Procurements::Mailers::Base::MailerPresenter.new(user, params, messages)
    # ProcurementMailer.delay.send_mail(document, email_options, user)
    ProcurementMailer.delay(queue: 'procurements_notification').send_mail(op)
  end

  def post_process
    add_message :success, 'Successfully sent mail'
  end

  def success
    Procurements::Mailers::Base::MailerPresenter.new(user, params, messages)
  end

  class Procurements::Mailers::Base::MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :document, :user, :email_to, :email_bcc_to, :email_subject, :email_body, :company, :attachments

    def init
      self.document = params[:document]
      # self.purchase_order = params[:document]
      self.email_body = params[:email_options][:email_body]
      self.email_to = params[:email_options][:email_to]
      self.email_bcc_to = params[:email_options][:email_bcc_to]
      self.email_subject = params[:email_options][:email_subject]
      self.attachments = params[:attachments]
      self.company = user.company
    end
  end
end