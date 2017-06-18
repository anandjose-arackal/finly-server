class Receipt::ReceiptEmails::Extractor::Adapter::Drivojoy < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'invoice@drivojoy.com'
  end

  def self.mail_keywords
    'invoice@drivojoy.com'
  end

  def merchant
    'Drivojoy'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td+ td b')
    ]
  end

end
