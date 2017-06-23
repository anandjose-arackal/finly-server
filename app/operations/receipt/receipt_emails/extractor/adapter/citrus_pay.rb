class Receipt::ReceiptEmails::Extractor::Adapter::CitrusPay < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'noreply@citruspay.com'
  end

  def merchant
    'Citrus Pay'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=tbl-details]', css_selector_regex: Receipt::ReceiptEmails::Extractor::Adapter::Base::REGEX_AMOUNT_WITH_INR)
    ]
  end

end
