class Receipt::ReceiptEmails::Extractor::Adapter::Irctc < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['ticketadmin@irctc.co.in']
  end

  def merchant
    'IRCTC'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td+ td', position: :last)
    ]
  end

end
