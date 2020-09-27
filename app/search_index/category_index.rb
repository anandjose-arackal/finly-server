class CategoryIndex < SearchIndex::Model
  index Indexes::VpRecords do
    serialize do |record|
      {
          cost_center_name: [record.name],
          cost_center_codes: [record.category_code],
          gl_code: record.gl_code
      }
    end
  end
end