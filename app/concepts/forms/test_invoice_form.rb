class Forms::TestInvoiceForm < Forms::API

  # model Invoice
  # section :header do
  #   auto_number :invoice_id, prefix: "INV/{{\"now\" | date: \"%y-%m\" }}/", start_at: '000001', required: true
  #   date :date, required: true
  #   date :due_date, required: true
  #   text :invoice_number, required: true
  #   number :gst_type_id, required: true, scope: Forms::DSL::Entity::Scopes::Enum.new(GstType, :id, :name)
  #   number :discount, decimal: true, default_value: 0
  #   amount :discount_amount
  #   amount :gross_amount, required: true
  #   amount :net_amount, required: true
  #   boolean :inclusive_of_taxes
  #   amount :amount, required: true
  #   number :tds
  #   # number :tds_slab_id, scope: Forms::DSL::Entity::Scopes::Resolver.new(Masters::Tds::Resolver, :id, :name)
  # end
  #
  # section :line_items do
  #   collection :line_items do
  #     text :item_description, hint: "Please enter the name of the field", char_limit: 255
  #     dropdown :status_id, scope: Forms::DSL::Entity::Scopes::List({value: 1, name: 'Approved'}, {value: 2, name: 'Pending'})
  #     dropdown :department_id, scope: Forms::DSL::Entity::Scopes::AutoComplete('departments', filters: {})
  #     dropdown :location_id, scope: Forms::DSL::Entity::Scopes::AutoComplete('locations', filters: {})
  #     dropdown :cost_center_id, scope: Forms::DSL::Entity::Scopes::AutoComplete('cost_centers', filters: {})
  #     # dropdown :location_id, choices: ReportStatus.all.as_json
  #   end
  # end

end