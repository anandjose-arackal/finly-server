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
    text value: -> (context) { context[:record].started_at&.strftime("%I:%M:%S %p, %d %b %Y") }
  end

  column :ended_at, default: true do
    text value: -> (context) { context[:record].ended_at&.strftime("%I:%M:%S %p, %d %b %Y") }
  end

  column :execution_time, default: true do
    text value: :execution_time
  end

  column :status, default: true do
    indicator value: '{{record.status.name}}', format: :format_status
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :active_eq
    counter.add nil, "All", collection.count
    counter
  end

  def self.execution_time(context)
    return nil if context[:record].started_at.blank?
    return nil if context[:record].ended_at.blank?
    secs = context[:record].ended_at - context[:record].started_at
    TimeUtils.humanize_seconds(secs)
  end

  def self.format_status(context)
    case context[:exposure].status.id
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