class Admin::Masters::Macros::Jobs::Index < IndexBuilder::API

  permissions :admin
  system_subscription :ap
  resolver 'admin.macro_jobs.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :id, label: 'Job ID', fixed: true, sort: true do
    text value: :id, format: 'primary'
  end

  column :started_at, default: true, sort: true do
    date value: :started_at
  end

  column :ended_at, default: true do
    date value: :ended_at
  end

  column :status, default: true do
    text value: '{{record.status.name}}'
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :active_eq
    counter.add nil, "All", collection.count
    counter
  end

end