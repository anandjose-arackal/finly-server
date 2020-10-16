class DepartmentIndex < SearchIndex::Model

  index Indexes::VpRecords do

    serialize do |record|
      {
          description: record.full_name,
          sequence_id: record.department_code,
          gl_code: record.gl_code
      }
    end
  end

end