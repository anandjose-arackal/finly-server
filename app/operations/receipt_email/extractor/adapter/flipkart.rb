class ReceiptEmail::Extractor::Adapter::Flipkart < ReceiptEmail::Extractor::Adapter::Base

  def self.senders
    'no-reply@flipkart.com'
  end

  def self.mail_keywords
    'flipkart.com'
  end

  def merchant
    'Flipkart Pvt Ltd'
  end

  def amount_data_points
    ReceiptEmail::Extractor::Adapter::DataPoint.css_selector_mode('[class*=container] td span', REGEX_AMOUNT)
  end

end
