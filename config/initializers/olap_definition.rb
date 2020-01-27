module OLAPDefinition
  def olap_references
    column :finly_ref_id, 'integer', index: true, null: false, limit: 8
    column :finly_ref_created_at, 'datetime', index: true
    column :finly_ref_updated_at, 'datetime', index: true
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.include OLAPDefinition