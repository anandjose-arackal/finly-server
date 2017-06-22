class Receipt::ReceiptEmails::Extractor::Adapter::Housejoy < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['bookings@housejoy.in']
  end

  def merchant
    'Housejoy'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:has(td:contains("Grand Total"))', position: :last)
    ]
  end

end
