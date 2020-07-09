class Admin::Masters::Macros::Ops::Index < IndexBuilder::API

  resolver 'admin.macros.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :macro_id, label: 'Macro ID', fixed: true, sort: true do
    text value: :macro_id, format: 'primary'
  end

  column :name, default: true, sort: true do
    text value: "{{record.name}}"
  end

  column :description, default: true do
    text value: :description
  end

  column :active, default: true, includes: [:macro_type] do
    text value: :macro_status
  end

  column :last_run_at, sort: true, default: true do
    text value: -> (context) do
      user = context[:record]
      if user.last_run_at
        val = time_ago_in_words(user.last_activity_at)
        "#{val} ago" if val.present?
      else
        "Never"
      end
    end
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :active_eq
    counts = collection.group(:active).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    counter.add true, "Active", counts[true].to_i
    counter.add true, "Inactive", counts[false].to_i + counts[nil].to_i
    counter
  end

  def self.macro_status(context)
    user = context[:record]
    if user.active
      'Active'
    else
      'Inactive'
    end
  end

end