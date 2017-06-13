class ReceiptEmail::Extractor::Adapter::UberIndia < ReceiptEmail::Extractor::Adapter::Base

  def self.senders
    'uber.india@uber.com'
  end

  def self.mail_keywords
    'uber.com'
  end

  def merchant
    'Uber India'
  end

  def amount_data_points
    # ReceiptEmail::Extractor::Adapter::DataPoint.css_selector_mode('.topPrice', /[0-9\\.]+/)
    ReceiptEmail::Extractor::Adapter::DataPoint.css_selector_mode('[class*=topPrice]', REGEX_AMOUNT)
  end

end
