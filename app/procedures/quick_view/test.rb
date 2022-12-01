class QuickView::Test < QuickView::API

  class QuickView::Test::Summary < QuickView::Builders::Tab

    section :request do
      text :shipping_address, value: "{{record.shipping_address}}", label: "Test ID"
      text :billing_address, value: "{{record.billing_address}}"

      # attachment :pan_card, "{{record.pan_card.url}}"

      table :table_1, data: Proc.new {|context| context[:exposure].line_items }  do
        text :quantity, value: "{{record.quantity}}"
      end

      table :table_2, resolver: "invoice_line_items.default", params: {q: {id_eq: "{{params.id}}"}, per_page: 10}, paginate: true, search: true do
        text :description, value: "{{record.description}}", label: "Test Description"
        text :quantity, value: "{{record.quantity}}"
      end
    end
  end

  model Invoice
  policy Docs::P2P::Invoices::Policy, :show?
  tab :summary, default: true, builder: QuickView::Test::Summary

end
