class Receipt::ReceiptEmails::Extractor::Adapter::GoAir < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['reservations@goair.in']
  end

  def merchant
    'GoAir'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table:contains("Payment Summary") tr:contains("TOTAL PAYMENTS")')
    ]
  end

end
