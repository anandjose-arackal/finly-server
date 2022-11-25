class IndexBuilder::ContentTypes::DataCard < IndexBuilder::ContentTypes::Base

  register :data_card

  attribute :value
  attribute :id
  attribute :route

end