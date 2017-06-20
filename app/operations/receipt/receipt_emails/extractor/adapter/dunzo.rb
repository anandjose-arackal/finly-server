class Receipt::ReceiptEmails::Extractor::Adapter::GoIbibo < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['support@dunzo.in']
  end

  def merchant
    'Dunzo'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr+ td:contains("You have paid")')
    ]
  end

end
