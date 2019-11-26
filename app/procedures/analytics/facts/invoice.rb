class Analytics::Facts::Invoice < Analytics::Mapper

  # def self.map(prop)
  #   property prop, deserialize(-> (input, represented, record:, **) do
  #     represented.send("#{prop}=", yield)
  #   end)
  # end

  # events 'invoice.update'
  # input -> (user, payload) {
  #   payload[:record]&.items
  # }
  # # fact OLAP::Payable
  #
  # field :entity do
  #   record
  # end
  # field :parent do
  #   record.invoice
  # end
  # field :company do
  #   record.user.company
  # end
  # field :category do
  #   record.category
  # end
  # field :gl_code do
  #   record.category.gl_code
  # end
  # field :cost_center_id do
  #   record.cost_center_id
  # end
  # field :parent_billing_location_id do
  #   record.invoice.billing_location.parent_id
  # end
  # field :billing_location_id do
  #   record.invoice.billing_location.parent_id
  # end
  # field :parent_shipping_location_id do
  #   record.invoice.billing_location.parent_id
  # end
  # field :shipping_location_id do
  #   record.invoice.billing_location.parent_id
  # end
  # field :parent_department_id do
  #   record.invoice.billing_location.parent_id
  # end
  # field :department_id do
  #   record.invoice.billing_location.parent_id
  # end
  # field :vendor_id do
  #   record.invoice.billing_location.parent&.name
  # end


end