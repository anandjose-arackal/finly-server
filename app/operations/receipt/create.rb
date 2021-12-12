class Receipt::Create < Receipt::Base
  attr_accessor :receipt, :receipt_params

  def pre_validate
    if params.blank? or params&.dig(:receipt).blank? or user.blank?
      add_message :error, 'Image cannot be blank'
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    self.receipt_params = create_params
  end

  def validate
    if user.company.ocr_enabled?
      if receipt_params[:to_be_transcribed].nil?
        receipt_params[:to_be_transcribed] = '1'
      end
    else
      receipt_params.delete(:to_be_transcribed)
    end
  end

  def pre_process
    receipt_params[:created_by_id] = actual_current_user.id if actual_current_user.present?
  end

  def process
    self.receipt = user.receipts.build(receipt_params)
    unless receipt.save
      add_message :error, receipt.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Receipt added'

    # if the company has receipt transcription enabled, it will be marked on the receipt and trigger a mailer
    # to notify us about  receipt being uploaded
    if user.company.ocr_enabled? && receipt.reload.to_be_transcribed

      ########## Mailer being triggered ###########
      if Rails.env.production?
        Constants::TRANSCRIBER_EMAILS.each do |email|
          ReceiptMailer.delay.notify_receipt_upload(user.company, user, receipt, email)
        end
      end
      #############################################
    end

    # if attachment is a pdf format then convert each page to an image file and store in +DocumentSlice+
    if receipt.is_pdf?
      DocumentSlice::Create.call_async(user.id, {receipt_id: receipt.id})
    end
  end

  def success
    Receipt::Create::ReceiptPresenter.new(user, {receipt: receipt}, messages)
  end

  class Receipt::Create::ReceiptPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :receipt

    def init
      self.receipt = params[:receipt]
    end
  end

  private
  def create_params
    p = params.require(:receipt).permit(:image, :note, :to_be_transcribed, :created_by_id)
    p[:image] = params[:receipt][:image] rescue nil
    p.permit!
  end

end