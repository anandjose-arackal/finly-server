class Receipt::ReceiptEmails::Extractor::Adapter::AmazonIndia < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'auto-confirm@amazon.in'
  end

  def self.mail_keywords
    'auto-confirm@amazon.in'
  end

  def merchant
    'Amazon India'
  end

  def amount_data_points
    [
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('[class*=total]+ [class*=total] strong', REGEX_AMOUNT),
      Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td tr+ tr strong', REGEX_AMOUNT)
    ]
  end

  # Amazon sometimes breaks down orders into multiple orders in the same email, hence have to parse through all items to extract and sum the order total
  def amount_value
    data_points = amount_data_points
    return nil if data_points.blank?
    data_points = [data_points] unless data_points.is_a?(Array)
    data_points.each do |data_point|
      next unless data_point.is_a?(Receipt::ReceiptEmails::Extractor::Adapter::DataPoint)
      amount_val = 0
      parser&.css(data_point.css_selector)&.each do |selector|
        amount_val += (selector.text[data_point.css_selector_regex].to_f rescue 0)
      end
      return amount_val if amount_val.present? and amount_val > 0
    end
    nil
  end

end
