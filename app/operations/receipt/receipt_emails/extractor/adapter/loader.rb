class Receipt::ReceiptEmails::Extractor::Adapter::Loader

  ADAPTERS = [
      # Travel
      Receipt::ReceiptEmails::Extractor::Adapter::UberIndia,
      Receipt::ReceiptEmails::Extractor::Adapter::OlaCabs,
      Receipt::ReceiptEmails::Extractor::Adapter::MeruCabs,
      Receipt::ReceiptEmails::Extractor::Adapter::Irctc,
      Receipt::ReceiptEmails::Extractor::Adapter::Redbus,
      Receipt::ReceiptEmails::Extractor::Adapter::MakeMyTrip,
      Receipt::ReceiptEmails::Extractor::Adapter::GoIbibo,
      Receipt::ReceiptEmails::Extractor::Adapter::GoAir,
      Receipt::ReceiptEmails::Extractor::Adapter::IndiGo,
      Receipt::ReceiptEmails::Extractor::Adapter::OyoRooms,

      # Shopping
      Receipt::ReceiptEmails::Extractor::Adapter::Flipkart,
      Receipt::ReceiptEmails::Extractor::Adapter::AmazonIndia,
      Receipt::ReceiptEmails::Extractor::Adapter::Chumbak,

      # Food Delivery
      Receipt::ReceiptEmails::Extractor::Adapter::Swiggy,
      Receipt::ReceiptEmails::Extractor::Adapter::ZomatoIndia,
      Receipt::ReceiptEmails::Extractor::Adapter::FreshMenu,
      Receipt::ReceiptEmails::Extractor::Adapter::FoodPandaIndia,
      Receipt::ReceiptEmails::Extractor::Adapter::Box8,

      # Invoice
      Receipt::ReceiptEmails::Extractor::Adapter::AirtelMobileIndia,
      Receipt::ReceiptEmails::Extractor::Adapter::BigRock,
      Receipt::ReceiptEmails::Extractor::Adapter::GoDaddy,

      # Bookings
      Receipt::ReceiptEmails::Extractor::Adapter::BookMyShow,

      # Services
      Receipt::ReceiptEmails::Extractor::Adapter::Dunzo,
      Receipt::ReceiptEmails::Extractor::Adapter::Drivojoy,
      Receipt::ReceiptEmails::Extractor::Adapter::Housejoy,
      Receipt::ReceiptEmails::Extractor::Adapter::Furlenco,

      # Payment
      Receipt::ReceiptEmails::Extractor::Adapter::PaypalOrder,
      Receipt::ReceiptEmails::Extractor::Adapter::Paytm,
      Receipt::ReceiptEmails::Extractor::Adapter::CitrusPay,
      Receipt::ReceiptEmails::Extractor::Adapter::PayU

      # Others
  ]

  def self.adapter_for(user, sender, sent_at, subject, html_body)
    ADAPTERS.each do |adapter|
      if adapter.can_parse?(user, sender, sent_at, subject, html_body)
        return adapter.new(user, sender, sent_at, subject, html_body)
      end
    end
    Receipt::ReceiptEmails::Extractor::Adapter::Generic.new(user, sender, sent_at, subject, html_body)
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
