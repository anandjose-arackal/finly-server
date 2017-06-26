class Receipt::ReceiptEmails::Extractor::Adapter::Box8 < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'order@box8letters.com'
  end

  def merchant
    'Box8'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td:contains("Total Payable") span')
    ]
  end

end
