class Receipt::ReceiptEmails::Extractor::Adapter::GoIbibo < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['noreply@goibibo.com']
  end

  def merchant
    'GoIbibo'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=contentTxt]+ [class*=contentTxt]')
    ]
  end

end
