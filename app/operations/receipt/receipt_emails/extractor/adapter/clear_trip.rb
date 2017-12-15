class Receipt::ReceiptEmails::Extractor::Adapter::ClearTrip < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['no-reply@cleartrip.com']
  end

  def merchant
    'ClearTrip'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('h1:contains("Amount paid")'),
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('h1:contains("Amount")')
    ]
  end

end
