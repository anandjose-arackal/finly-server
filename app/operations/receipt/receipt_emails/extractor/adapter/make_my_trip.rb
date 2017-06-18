class Receipt::ReceiptEmails::Extractor::Adapter::MakeMyTrip < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['noreply@makemytrip.com']
  end

  def merchant
    'MakeMyTrip'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td:contains("Total Amount Charged") td:contains("Total Amount Charged")'),
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td:contains("Total Amount Charged")'),
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td:contains("Total Fare")')
    ]
  end

end
