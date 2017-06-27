class Receipt::ReceiptEmails::Extractor::Adapter::Chumbak < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'help@chumbak.in'
  end

  def merchant
    'Chumbak'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=grand_total] [class*=price]'),
    ]
  end

end
