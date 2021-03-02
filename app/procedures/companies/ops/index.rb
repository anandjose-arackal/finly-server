class Companies::Ops::Index < IndexBuilder::API

  system_subscription :em, :vp
  permissions :admin
  resolver 'companies.default'
  reference '{{record.id}}'
  action_route 'companies.index.row'

  column :name, fixed: true, sort: :name do
    text value: "{{record.name}}", format: 'primary'
  end

  column :legal_entity_name, label: 'Legal Name', default: true do
    text value: "{{record.configuration.legal_entity_name}}"
  end

  column :start_date, default: true do
    date value: "{{record.configuration.start_date}}"
  end

  column :end_date, default: true do
    date value: "{{record.configuration.end_date}}"
  end

  column :active, default: true do
    indicator value: :active, format: :active_status
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :filter_state
    counter.add nil, "All", collection.count
    counter
  end

  def self.active_status(context)
    if context[:record].active?
      'Active'
    else
      'Inactive'
    end
  end
end