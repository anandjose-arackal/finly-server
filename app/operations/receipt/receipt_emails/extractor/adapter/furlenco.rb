class Receipt::ReceiptEmails::Extractor::Adapter::Furlenco < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'billing@furlenco.com'
  end

  def merchant
    'Furlenco'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:contains("Amount")')
    ]
  end

end
