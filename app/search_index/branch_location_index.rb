class BranchLocationIndex < SearchIndex::Model
  index Indexes::VpRecords do

    record_type do |record|
      'locations'
    end

    serialize do |record|
      {
          location_names: [record.name],
          location_codes: [record.location_code],
          gl_code: record.gl_code
      }
    end
  end
end