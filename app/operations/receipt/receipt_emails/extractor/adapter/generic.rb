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

end