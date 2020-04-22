class Masters::RateContracts::Index < IndexBuilder::API

  resolver 'rate_contracts.default'
  reference '{{record.id}}'
  custom_fields :rate_contract

  # Fixed column is always default true
  column :vendor, label: 'Vendor', fixed: true, sort: :vendor_business_name, includes: [:vendor] do
    text value: "{{record.vendor.business_name}}", format: 'primary'
    text value: :vendor_trade_name
  end

  column :rate_contract_id, label: "Rate Contract ID", default: true, sort: :rate_contract_number do
    text value: :rate_contract_id, format: "primary"
  end

  column :name, label: "Contract Name", default: true, sort: :name do
    text value: "{{record.name}}"
  end

  column :vendor_id, sort: :vendor_id, label: "Vendor ID", default: true do
    text value: "{{record.vendor.vendor_id}}"
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :is_renewable, sort: :renewable, default: true do
    checkbox value: :renewable
  end

  column :note, default: true do
    text value: :note
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :with_status_id
    counter.add nil, "All", collection.count
    counter
  end

  def self.vendor_trade_name(context)
    return "Trade Name: #{context[:record].vendor.trade_name}" if context[:record].vendor.trade_name.present?

    nil
  end

end