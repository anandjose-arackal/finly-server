class Receipt::ReceiptEmails::Extractor::Adapter::FoodPandaIndia < Receipt::ReceiptEmails::Extractor::Adapter::Base

  def self.senders
    ['orders@newsletter.foodpanda.in']
  end

  def merchant
    'FoodPanda'
  end

  def amount_data_points
    [
        Receipt::ReceiptEmails::Extractor::Adapter::DataPoint.css_selector_mode('td+ td font strong')
    ]
  end

end
