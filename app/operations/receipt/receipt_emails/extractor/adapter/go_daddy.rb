class Receipt::ReceiptEmails::Extractor::Adapter::GoDaddy < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'billing@bigrock.com'
  end

  def merchant
    'BigRock'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:contains("Total")',position: :last)
    ]
  end

end
