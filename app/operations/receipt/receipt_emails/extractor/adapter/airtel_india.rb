class Receipt::ReceiptEmails::Extractor::Adapter::AirtelIndia < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'ebill@airtel.com'
  end

  def merchant
    'Airtel India'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:nth-child(2) td:nth-child(4)'),
    ]
  end

end
