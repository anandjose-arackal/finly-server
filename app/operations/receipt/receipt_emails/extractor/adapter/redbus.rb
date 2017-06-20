class Receipt::ReceiptEmails::Extractor::Adapter::Redbus < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'ticketmaster@redbus.in'
  end

  def merchant
    'Redbus'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('p:contains("Total Fare")'),
    ]
  end

end
