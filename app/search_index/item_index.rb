class ItemIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations :item_expense_type, :product_type, :supply_item_type, :category

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