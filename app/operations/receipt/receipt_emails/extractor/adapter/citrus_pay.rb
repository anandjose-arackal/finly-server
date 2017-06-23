class Receipt::ReceiptEmails::Extractor::Adapter::CitrusPay < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'billing@bigrock.com'
  end

  def merchant
    'BigRock'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td td td:contains("INR")')
    ]
  end

end
