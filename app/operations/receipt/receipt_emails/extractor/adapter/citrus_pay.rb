class Receipt::ReceiptEmails::Extractor::Adapter::CitrusPay < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'noreply@citruspay.com'
  end

  def merchant
    'Citrus Pay'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td td td:contains("INR")')
    ]
  end

end
