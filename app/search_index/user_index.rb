class UserIndex < SearchIndex::Model

  index Indexes::VpRecords do
    include_associations(:profile)

    serialize do |record|
      {
          user_name: record.name,
          user_email: record.email,
          employee_id: record.profile&.employee_id,
          status_name: record.status&.titleize
      }
    end

  end
end