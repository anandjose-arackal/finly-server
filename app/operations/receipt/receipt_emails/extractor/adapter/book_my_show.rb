class Receipt::ReceiptEmails::Extractor::Adapter::BookMyShow < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'tickets@bookmyshow.email'
  end

  def merchant
    'BookMyShow'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table table:contains("AMOUNT PAID") tr:contains("AMOUNT PAID")')
    ]
  end

end
