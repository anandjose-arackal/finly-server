class Analytics::Dimensions::Category < Analytics::Mapper

  model ::Category
  events %w(category.update category.create)
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