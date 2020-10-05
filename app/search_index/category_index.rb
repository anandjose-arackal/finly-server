class CategoryIndex < SearchIndex::Model
  index Indexes::VpRecords do

    serialize do |record|
      {
          description: record.name,
          sequence_id: record.category_code,
          category_name: [record.name],
          category_code: [record.category_code],
          gl_code: record.gl_code
      }
    end

  end
end