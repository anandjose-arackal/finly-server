class Docs::P2P::Inwards::Pending::Index < IndexBuilder::API
  include DynamicAttributes

  system_subscription :vp
  permissions Docs::P2P::Inwards::Received::Index.permissions
  resolver 'inward_documents.pending'
  reference '{{record.procurement_id}}'
  selectable false

  # Fixed column is always default true
  column :vendor, label: 'Vendor Details', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: '{{record.vendor.business_name}}', format: 'primary'
    text value: "Vendor ID: {{record.vendor.vendor_id}}"
  end

  column :po_number, sort: :po_number, label: "PO Number", default: true do
    text value: :po_number, format: "primary"
  end

  column :name, label: "Name", default: true do
    text value: "{{record.name}}", format: "success"
  end

  column :expected_delivery_date, default: true, sort: :delivery_date do
    date value: :expected_delivery_date
  end

  column :status, default: true do
    text value: :status, format: :format_status
  end

  column :created_by, default: true, includes: [:created_by] do
    user value: :created_by
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :submitted_at, sort: :submitted_at do
    date value: :submitted_at
  end

  column :approved_at, sort: :approved_at do
    date value: :approved_at
  end

  column :cost_center, default: true, includes: [:cost_center] do
    text value: :cost_center_name
  end

  column :department, default: true, includes: [:department] do
    text value: :department_name
  end

  column :vendor_location, default: false, includes: [:gstin_location] do
    text value: "{{record.gstin_location.location}}"
  end

  column :billing_location, sort: :billing_location_name, default: false, includes: [:location] do
    text value: "{{record.billing_location.name}}"
  end

  column :shipping_location, sort: :shipping_location_name, default: false, includes: [:delivery_location] do
    text value: "{{record.shipping_location.name}}"
  end

  counter -> (user, collection) do
    # Use custom scope to support awaiting approval status
    counter = IndexBuilder::Counter.new :with_grn_status_id
    counter.add nil, "All", collection.count
    counter.add 100, 'Due this week', collection.with_grn_status_id(100).count
    counter.add 101, 'Due this month', collection.with_grn_status_id(101).count
    counter.add 102, 'Overdue', collection.with_grn_status_id(102).count
    counter.add 103, 'Upcoming', collection.with_grn_status_id(103).count
    counter
  end

  def self.cost_center_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].cost_center&.name
  end

  def self.department_name(context)
    return "Multiple" if context[:exposure].cost_allocation_items

    context[:exposure].department&.name
  end

  def self.status(context)
    record = context[:record]
    if record.delivery_date.present?
      if record.delivery_date >= Date.today and record.delivery_date <= Date.today.end_of_week
        return 'Expected this week'
      elsif record.delivery_date >= Date.today and record.delivery_date <= Date.today.end_of_month
        return 'Expected this month'
      elsif record.delivery_date < Date.today
        return 'Overdue'
      end
    end
    return 'Upcoming'
  end

  def self.format_status(context)
    record = context[:record]
    if record.delivery_date.present?
      if record.delivery_date >= Date.today and record.delivery_date <= Date.today.end_of_week
        return 'warning'
      elsif record.delivery_date >= Date.today and record.delivery_date <= Date.today.end_of_month
        return 'success'
      elsif record.delivery_date < Date.today
        return 'danger'
      end
    end
    return 'success'
  end

end