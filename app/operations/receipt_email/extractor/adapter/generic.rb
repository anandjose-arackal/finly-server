class ReceiptEmail::Extractor::Adapter::Generic < ReceiptEmail::Extractor::Adapter::Base

  def merchant
    if sender.present?
      return sender.split('@')&.last rescue nil
    end
    nil
  end

end