class DepartmentIndex < SearchIndex::Model

  index Indexes::VpRecords do
    serialize do |record|
      {
          department_names: [record.name],
          department_codes: [record.department_code],
          gl_code: record.gl_code
      }
    end
  end

end