class Masters::Schema::Ops::Index < IndexBuilder::API

  system_subscription :vp
  permissions :admin
  resolver 'master_schemas.default'
  reference '{{record.master_key}}'

  column :name, fixed: true, sort: :name do
    text value: "{{record.name}}", format: 'primary'
  end

  column :master_key, default: true do
    text value: "{{record.master_key}}"
  end

  column :active, default: true do
    indicator value: :active, format: :active_status
  end

  def self.active_status(context)
    if context[:record].active?
      'Active'
    else
      'Inactive'
    end
  end

end