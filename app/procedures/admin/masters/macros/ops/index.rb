class Admin::Masters::Macros::Ops::Index < IndexBuilder::API

  permissions :admin
  system_subscription :ap
  resolver 'admin.macros.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :macro_key, label: 'Macro Key', fixed: true, sort: true do
    text value: :macro_key, format: 'primary'
  end

  column :name, default: true, sort: true do
    text value: "{{record.name}}"
  end

  column :description, default: true do
    text value: :description
  end

  column :last_run_at, sort: true, default: true do
    text value: -> (context) do
      user = context[:record]
      if user.last_run_at
        val = time_ago_in_words(user.last_run_at)
        "#{val} ago" if val.present?
      else
        "Never"
      end
    end
  end

  column :last_run_status, default: true, includes: [:job] do
    indicator value: "{{record.job.status.name}}", format: :format_macro_job_status
  end

  column :active, default: true, includes: [:macro_type] do
    indicator value: :macro_status, format: :format_macro_status
  end

  column :start_date, default: true do
    date value: :start_date
  end

  column :end_date, default: true do
    date value: :end_date
  end

  column :run_as_user, default: true do
    text value: "{{record.user.name}}"
  end

  column :permissions, default: true do
    text value: -> (context) { context[:record].permissions&.map {|perm| perm.humanize}&.join(", ") }
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :is_active
    counts = collection.group(:active).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    counter.add 1, "Active", collection.is_active(true).count
    counter.add 0, "Inactive", collection.is_active(false).count
    counter
  end

  def self.macro_status(context)
    user = context[:record]
    if user.active?
      'Active'
    else
      'Inactive'
    end
  end

  def self.format_macro_status(context)
    user = context[:record]
    if user.active
      'success'
    else
      'danger'
    end
  end

  def self.format_macro_job_status(context)
    case context[:exposure].job&.status&.id
    when MacroJobStatus.id_for(:in_progress)
      return 'info'
    when MacroJobStatus.id_for(:completed)
      return 'success'
    when MacroJobStatus.id_for(:failed)
      return 'danger'
    else
      return 'warning'
    end
  end

end