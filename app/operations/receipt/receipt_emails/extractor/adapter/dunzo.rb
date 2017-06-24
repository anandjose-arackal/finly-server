class Receipt::ReceiptEmails::Extractor::Adapter::Dunzo < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['support@dunzo.in']
  end

  def merchant
    'Dunzo'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td td td:contains("TOTAL")')
    ]
  end

end
