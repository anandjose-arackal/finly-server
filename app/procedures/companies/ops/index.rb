class Companies::Ops::Index < IndexBuilder::API

  system_subscription :em, :vp
  permissions :admin
  resolver 'companies.default'
  reference '{{record.id}}'

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

  column :actions, default: true do
    action :button_group, :actions, contextual: false, label: 'Actions' do
      action :api_request,
            :disable,
            label: 'Disable',
            url: 'companies/{{record.id}',
            method: :patch,
            policy: Companies::Policy,
            authorize: :disable?,
            permissions: :admin,
            body: {
              active: false,
            },
            confirmation: "Are you sure you want to disable this entity?"
    end
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