class Receipt::ReceiptEmails::Extractor::Adapter::OyoRooms < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'no-reply@flipkart.com'
  end

  def merchant
    'Flipkart Pvt Ltd'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table div div:contains("Guest")')
    ]
  end

end
