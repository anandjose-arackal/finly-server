class Masters::Vendors::Index < IndexBuilder::API

  resolver 'vendors.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :vendor, label: 'Name', fixed: true, sort: :business_name do
    text value: "{{record.business_name}}", format: 'primary'
    text value: :vendor_trade_name
  end

  column :vendor_id, sort: :vendor_id, label: "Vendor ID", default: true do
    badge value: :vendor_id, format: "success"
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :vendor_type, sort: :vendor_type_name, default: true do
    text value: "{{record.vendor_type.name}}"
  end

  column :status, default: true, includes: [:status] do
    badge value: "{{record.status.name | upcase}}", format: :format_status
  end

  column :gst_registered, default: true do
    text value: :is_gst_registered
  end

  column :gstin, default: true, includes: [:gstin_locations] do
    text value: :vendor_gstin
  end

  column :locations, default: true, includes: [:gstin_locations] do
    text value: :vendor_locations
  end

  column :submitted_at, sort: :submitted_at do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at do
    date value: :approved_at
  end

  column :pan do
    text value: :pan
  end

  column :policy, default: true do
    text value: "{{record.policy.name}}"
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    VendorStatus.all.each do |status|
      counter.add status.id, status.name.humanize, counts[status.id]
    end
    counter
  end

  def self.is_gst_registered(user, record, record_exposure)
    return "Yes" if record.gst_registered

    "No"
  end

  def self.vendor_gstin(user, record, record_exposure)
    record.gstin_locations.map(&:gstin).join(', ')
  end

  def self.vendor_locations(user, record, record_exposure)
    record.gstin_locations.map(&:location)
  end

  def self.vendor_trade_name(user, record, record_exposure)
    return "Trade Name: #{record.trade_name}" if record.trade_name.present?

    nil
  end

  def self.format_status(user, record, record_exposure)
    case record.status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :approved, :auto_approved
      format = 'success'
    when :awaiting_approval
      if record.controlling_user_id == user.id
        format = 'warning'
      else
        format = 'info'
      end
    when :draft, :retracted, :deactivated
      format = 'info'
    else
      format = 'danger'
    end
    format
  end

end