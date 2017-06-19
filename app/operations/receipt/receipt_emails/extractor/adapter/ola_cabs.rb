class Receipt::ReceiptEmails::Extractor::Adapter::OlaCabs < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'noreply@olacabs.com'
  end

  def merchant
    'Ola Cabs'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=stamp-padding] td'),
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=cost-count]'),
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=body] div+ div div td div > span')
    ]
  end

end
