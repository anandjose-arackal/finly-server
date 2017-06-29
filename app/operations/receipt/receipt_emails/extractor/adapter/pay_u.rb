class Receipt::ReceiptEmails::Extractor::Adapter::PayU < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'donotreply@payumoney.com'
  end

  def merchant
    'PayU Money'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:has(td:contains("Amount Paid"):not(:has(*)))')
    ]
  end

end
