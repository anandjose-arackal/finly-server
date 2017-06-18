class Receipt::ReceiptEmails::Extractor::Adapter::Swiggy < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'noreply@swiggy.in'
  end

  def self.mail_keywords
    [{body: ['Thanks for using Swiggy! Your order']}]
  end

  def merchant
    'Swiggy'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=grand-total] td'),
    ]
  end

end
