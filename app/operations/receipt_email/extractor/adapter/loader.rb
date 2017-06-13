class ReceiptEmail::Extractor::Adapter::Loader

  ADAPTERS = [
    ReceiptEmail::Extractor::Adapter::UberIndia,
    ReceiptEmail::Extractor::Adapter::Flipkart,
    ReceiptEmail::Extractor::Adapter::OlaCabs
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
    ReceiptEmail::Extractor::Adapter::Generic
  end

end
