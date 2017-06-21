class Receipt::ReceiptEmails::Extractor::Adapter::BigRock < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'billing@bigrock.com'
  end

  def merchant
    'BigRock'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table table:contains("Invoice Details") tr td', position: :last),
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:contains("INR")',position: :last)
    ]
  end

end
