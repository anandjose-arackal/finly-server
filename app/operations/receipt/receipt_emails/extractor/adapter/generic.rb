class Receipt::ReceiptEmails::Extractor::Adapter::Generic < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def merchant
    if sender.present?
      return sender.split('@')&.last rescue nil
    end
    nil
  end

end