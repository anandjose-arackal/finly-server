class Receipt::ReceiptEmails::Extractor::Adapter::Google < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'payments-noreply@google.com'
  end

  def merchant
    'Google'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td:contains("USD"):not(:has(*))', position: :last)
    ]
  end

  def currency_id
    Currency.id_for('USD')
  end

end
