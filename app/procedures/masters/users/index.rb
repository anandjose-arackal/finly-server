class Masters::Users::Index < IndexBuilder::API

  resolver 'users.default'
  reference '{{record.id}}'

  column :name, label: 'Name', fixed: true, sort: :first_name do
    text value: :name, format: 'primary'
  end

  column :emp_id, label: 'Employee ID', sort: :profile_employee_id, default: true do
    text value: "{{record.profile.employee_id}}", format: 'primary'
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :status, sort: :status_name, default: true, includes: [:status] do
    indicator value: "{{record.status.name}}", format: :format_status
  end

end