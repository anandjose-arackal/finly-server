class Receipt::ReceiptEmails::Extractor::Adapter::IndiGo < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'reservations@goindigo.in'
  end

  def merchant
    'IndiGo'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table table:contains("Price Summary") tr:contains("Total Fare")', position: :last,
                                                                                css_selector_regex: Receipt::ReceiptEmails::Extractor::Adapter::Base::REGEX_AMOUNT_WITH_SPACE)
    ]
  end

end
