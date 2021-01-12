class Admin::CompanyGroups::Ops::Index < IndexBuilder::API

  permissions :admin
  system_subscription :ap
  resolver 'admin.company_groups.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :name, fixed: true, sort: true do
    text value: "{{record.name}}"
  end

  column :created_at, default: true do
    date value: :created_at
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :with_status_id
    counter.add nil, "All", collection.count
    counter
  end

end