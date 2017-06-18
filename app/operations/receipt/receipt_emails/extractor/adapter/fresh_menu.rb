class Receipt::ReceiptEmails::Extractor::Adapter::FreshMenu < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'order@freshmenu.com'
  end

  def self.mail_keywords
    'order@freshmenu.com'
  end

  def merchant
    'FreshMenu'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=mobile-padding] span strong', position: :last),
    ]
  end

end
