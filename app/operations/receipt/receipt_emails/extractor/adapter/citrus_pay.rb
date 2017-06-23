class Receipt::ReceiptEmails::Extractor::Adapter::CitrusPay < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'noreply@citruspay.com'
  end

  def merchant
    'Citrus Pay'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=tbl-details]', position_int: 2)
    ]
  end

end
