class CostCenterIndex < SearchIndex::Model

  index Indexes::VpRecords do

    serialize do |record|
      {
          description: record.full_name,
          sequence_id: record.cost_center_code,
          gl_code: record.gl_code
      }
    end
  end

end