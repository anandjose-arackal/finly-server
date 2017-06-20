class Receipt::ReceiptEmails::Extractor::Adapter::OyoRooms < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'service@intl.paypal.com'
  end

  def merchant
    'PayPal'
  end

  def currency_id
    Currency.id_for('USD')
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr tr tr:contains("Total")')
    ]
  end

end
