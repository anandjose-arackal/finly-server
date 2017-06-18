class Receipt::ReceiptEmails::Extractor::Adapter::UberIndia < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'uber.india@uber.com'
  end

  def merchant
    'Uber India'
  end

  def amount_data_points
    # Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('.topPrice', /[0-9\\.]+/)
    Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=topPrice]')
  end

end
