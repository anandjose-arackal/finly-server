class Receipt::ReceiptEmails::Extractor::Adapter::PayTM < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'alerts@paytm.com'
  end

  def merchant
    'PayTM'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('div div div div:contains("You have made a payment of', css_selector_regex: Receipt::ReceiptEmails::Extractor::Adapter::Base::REGEX_AMOUNT_WITH_RS, strip: ['Rs', 'Rs.', 'Rs. ']),
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('table tr:contains("Amount paid")')
    ]
  end

  def amount_value
    # Try extracting amount from subject itself. If not available then look at body
    val = subject[/Rs(\.)?(\s)?[1-9]\d*((,|\.)\d+)/]
    ['Rs. ', 'Rs', 'Rs.', ',', ' '].each do |text|
      val = val&.gsub(text, '')
    end
    if val.present?
      return val
    else
      return super
    end
  end

end
