class BranchLocationIndex < SearchIndex::Model
  index Indexes::VpRecords do

    record_type do |record|
      'locations'
    end

    serialize do |record|
      {
          description: record.name,
          sequence_id: record.location_code,
          gl_code: record.gl_code
      }
    end
  end
end