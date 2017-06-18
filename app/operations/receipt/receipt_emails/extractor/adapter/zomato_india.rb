class Receipt::ReceiptEmails::Extractor::Adapter::ZomatoIndia < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'order@zomato.com'
  end

  def self.mail_keywords
    'Thanks for ordering with Zomato!'
  end

  def merchant
    'Zomato'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=ta-right]', {position: :last})
    ]
  end

end
