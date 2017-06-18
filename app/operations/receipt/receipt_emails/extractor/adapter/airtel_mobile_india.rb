class Receipt::ReceiptEmails::Extractor::Adapter::AirtelMobileIndia < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'ebill@airtel.com'
  end

  def mail_keywords
    [
        {
            subject: 'Your airtel Bill for Mobile Number'
        }
    ]
  end

  def merchant
    'Airtel India'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:nth-child(2) td:nth-child(4)'),
    ]
  end

end
