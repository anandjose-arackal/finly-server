class BackgroundJobs::UtrUpdateEmail::SendInvoiceEmailOnUtrUpdateBackground
  include Sidekiq::Worker
  sidekiq_options queue: :payment_utr_emails, retry: 2

  def perform(payment_id)
    # fetching a new instance from database to ensure UTR number exists within the database record while sending email
    payment = Payment.find_by(id: payment_id) if payment_id.present?
    if payment.present? and payment.utr.present? and payment.invoice.present?
      document_owner = payment.invoice.created_by
      Event::EInvoice::UtrUpdate.(document_owner, { payment: payment })
    end
  end
end
