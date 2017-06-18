class Receipt::ReceiptEmails::Extractor::Adapter::Loader

  ADAPTERS = [
    Receipt::ReceiptEmails::Extractor::Adapter::UberIndia,
    Receipt::ReceiptEmails::Extractor::Adapter::Flipkart,
    Receipt::ReceiptEmails::Extractor::Adapter::OlaCabs,
    Receipt::ReceiptEmails::Extractor::Adapter::AmazonIndia,
    Receipt::ReceiptEmails::Extractor::Adapter::Swiggy,
    Receipt::ReceiptEmails::Extractor::Adapter::ZomatoIndia
  ]

  def self.adapter_for(sender, html)
    if sender.present?
      ADAPTERS.each do |adapter|
        senders = adapter.senders
        senders = [senders] unless senders.is_a?(Array)
        if senders.include? sender
          return adapter
        end
      end
    end

    if html.present?
      ADAPTERS.each do |adapter|
        mail_keywords = adapter.mail_keywords
        mail_keywords = [mail_keywords] unless mail_keywords.is_a?(Array)
        mail_keywords.each do |keyword|
          if html.include? keyword
            return adapter
          end
        end
      end
    end
    Receipt::ReceiptEmails::Extractor::Adapter::Generic
  end

  def self.known_sender?(sender)
    if sender.present?
      ADAPTERS.each do |adapter|
        senders = adapter.senders
        senders = [senders] unless senders.is_a?(Array)
        if senders.include? sender
          return true
        end
      end
    end
    false
  end

end
