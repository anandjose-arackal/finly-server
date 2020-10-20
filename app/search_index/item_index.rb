class ItemIndex < SearchIndex::Model

  index Indexes::Vp do
    include_associations :item_expense_type, :product_type, :supply_item_type, :category

    document_type :items
    permissions Masters::Items::Index.permissions
    category :masters
    route 'inventory/{{record_id}}/params={}'
    layout(
        {
            fixed_left: [:description, :sequence_id],
            fixed_right: [:category_name, :status_name]
        }
    )

    serialize do |record|
      {
          description: record.description,
          category_name: record.category&.name,
          category_code: record.category&.category_code,
          sequence_id: record.item_number,
          gl_code: record&.category&.gl_code,
          status_name: 'Active',
          company_id: record.company_id.to_s
      }
    end

    condition do |record|
      record.deleted_at.nil? and record.active
    end

  end

end