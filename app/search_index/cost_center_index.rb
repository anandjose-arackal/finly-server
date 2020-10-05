class CostCenterIndex < SearchIndex::Model

  index Indexes::VpRecords do

    serialize do |record|
      {
          description: record.name,
          sequence_id: record.cost_center_code,
          cost_center_names: [record.name],
          cost_center_codes: [record.cost_center_code],
          gl_code: record.gl_code
      }
    end
  end

end