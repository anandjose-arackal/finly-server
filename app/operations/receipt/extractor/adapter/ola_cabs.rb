class ReceiptEmail::Extractor::Adapter::OlaCabs < ReceiptEmail::Extractor::Adapter::Base

  def self.senders
    'noreply@olacabs.com'
  end

  def self.mail_keywords
    'olacabs.com'
  end

  def merchant
    'Ola Cabs'
  end

  def amount_data_points
    [
      ReceiptEmail::Extractor::Adapter::DataPoint.css_selector_mode('[class*=stamp-padding] td', REGEX_AMOUNT),
      ReceiptEmail::Extractor::Adapter::DataPoint.css_selector_mode('[class*=body] div+ div div td div > span', REGEX_AMOUNT)
    ]
  end

end
