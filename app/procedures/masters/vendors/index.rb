class Masters::Vendors::Index < IndexBuilder::API

  resolver 'vendors.default'
  reference '{{record.id}}'

  # Fixed column is always default true
  column :vendor, label: 'Name', fixed: true, sort: :business_name do
    text value: "{{record.business_name}}", format: 'primary'
    text value: :vendor_trade_name
  end

  column :vendor_id, sort: :vendor_id, label: "Vendor ID", default: true do
    text value: :vendor_id, format: "primary"
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :vendor_type, sort: :vendor_type_name, default: true do
    text value: "{{record.vendor_type.name}}"
  end

  column :status, default: true, includes: [:status] do
    badge value: :status_name, format: :format_status
  end

  column :gst_registered, default: true do
    checkbox value: :gst_registered
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

  IndexBuilder::API::ColumnTemplate::ControllingUser(self)
  IndexBuilder::API::ColumnTemplate::ControllingLevel(self)
  IndexBuilder::API::ColumnTemplate::ReviewProgress(self)

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :with_status_id
    counts = collection.group(:status_id).count
    counter.add nil, "All", counts.values.reduce(0, :+)
    # draft retracted
    counter.add 90, 'Open', ((counts[VendorStatus.id_for(:draft)].to_i) + (counts[VendorStatus.id_for(:retracted)].to_i))

    if user.has_permission?(:vendor_reviewer)
      counter.add 91, 'Awaiting Approval',
                  YesBankVendor.awaiting_action_items(user.id).count
    end

    # processing
    counter.add VendorStatus.id_for(:awaiting_approval), 'Processing', counts[VendorStatus.id_for(:awaiting_approval)]

    # approved auto_approved
    counter.add 92, 'Approved', (
    (counts[VendorStatus.id_for(:approved)].to_i) +
        (counts[VendorStatus.id_for(:auto_approved)].to_i)
    )

    # rejected, deactivated
    [:rejected, :deactivated].each do |status|
      counter.add VendorStatus.id_for(status), status.to_s.titleize, counts[VendorStatus.id_for(status)]
    end

    counter
  end

  def self.vendor_gstin(context)
    context[:record].gstin_locations.map(&:gstin).join(', ')
  end

  def self.vendor_locations(context)
    context[:record].gstin_locations.map(&:location)
  end

  def self.vendor_trade_name(context)
    return "Trade Name: #{context[:record].trade_name}" if context[:record].trade_name.present?

    nil
  end

  def self.status_name(context)
    return "Processing" unless context[:record].controlling_user?(context[:user])

    context[:record].status&.name
  end

  def self.format_status(context)
    case context[:record].status&.name&.to_s&.to_sym
    when :rejected
      format = 'danger'
    when :approved, :auto_approved
      format = 'success'
    when :awaiting_approval
      if context[:record].controlling_user?(context[:user])
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