class Receipt::ReceiptEmails::Extractor::Adapter::Envato < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    'do-not-reply@envato.com'
  end

  def merchant
    'Envato'
  end

  def amount_data_points
    []
  end

end
