class Receipt::ReceiptEmails::Extractor::Adapter::GoDaddy < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'donotreply@godaddy.com'
  end

  def merchant
    'GoDaddy'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:contains("Total")',position: :last)
    ]
  end

end
