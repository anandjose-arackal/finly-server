class Receipt::ReceiptEmails::Extractor::Adapter::MeruCabs < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'ebill@merucabs.com'
  end

  def merchant
    'Meru Cabs'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table table td:contains("Fare payable")')
    ]
  end

end
