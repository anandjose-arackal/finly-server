class PaymentOrderExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :scheduled_at, record_attribute: true
  attribute :processed_at, record_attribute: true
  attribute :amount_requested, record_attribute: true, exposure: true, includes: [amount_requested: :currency]
  attribute :amount_processed, record_attribute: true, exposure: true, includes: [amount_processed: :currency]
  attribute :bank_payment_request, record_attribute: true, exposure: true, includes: [:bank_payment_request]
  attribute :attachment_urls, includes: [:payment_order_attachments] do
    urls = []
     record.payment_order_attachments.map {|pt_attachment| urls << pt_attachment&.attached_file&.url(:original, timestamp: false)}
    urls.join(',')
  end

end