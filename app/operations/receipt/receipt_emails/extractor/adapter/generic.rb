class Receipt::ReceiptEmails::Extractor::Adapter::Generic < Receipt::ReceiptEmails::Extractor::Adapter::Base

  PERSONAL_EMAILS = ['gmail.com', 'yahoo.com', 'yahoo.co.in']

  def merchant
    if sender.present?
      s = sender.split('@')&.last rescue nil
      if PERSONAL_EMAILS.include?(s)
        return nil
      end
      return s
    end
    nil
  end

  # def amount_data_points
  #   keywords = ['Amount Paid', 'Total Amount', 'Grand Total', 'Shipment Total', 'Total', 'Paid']
  #   [
  #       Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('tr:has(td:contains("Amount Paid"):not(:has(*)))')
  #   ]
  #   arr = []
  #   keywords.each do |keyword|
  #     arr << Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode("tr:has(td:contains(\"#{keyword}\"):not(:has(*)))")
  #   end
  # end


end