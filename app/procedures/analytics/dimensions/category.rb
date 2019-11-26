class Analytics::Dimensions::Category < Analytics::DSL

  model ::Category
  events 'category.update', 'category.create'
  dimension Olap::Dimensions::Category
  # input -> (user, payload) {
  #   payload[:record]
  # }
  # fact OLAP::Payable

  # field :code
  field :name
  field :gl_code
  field :active

end