class ImportJobs::Index < IndexBuilder::API

  system_subscription :vp
  resolver 'import_jobs.default'
  reference '{{record.id}}'

  column :name, fixed: true do
    text value: "{{record.name}}", format: 'primary'
  end

  column :progress, default: true do
    progress_bar value: ->(context) { context[:record].completion_percentage || 0 },
                 completed_count: ->(context) { context[:record].completed_records || 0 },
                 total_count: ->(context) { context[:record].total_records || 0 }
  end

  column :created, default: true do
    text value: "Created: {{record.created_records}}, Updated: {{record.updated_records}}"
    text value: "Failed: {{record.failed_records}}, Skipped: {{record.skipped_records}}"
  end

  column :attachment, default: true do
    # Todo
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :with_status_id
    counter.add nil, "All", collection.count
    counter
  end

end