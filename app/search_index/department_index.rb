class DepartmentIndex < SearchIndex::Model

  index Indexes::VpRecords do

    serialize do |record|
      {
          description: record.name,
          sequence_id: record.department_code,
          department_names: [record.name],
          department_codes: [record.department_code],
          gl_code: record.gl_code
      }
    end
  end

end