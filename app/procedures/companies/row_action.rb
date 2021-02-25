class Companies::RowAction < ActionManager::API
  scope policy: Companies::Policy, model: Company do
    action :api_request,
           :disable,
           label: 'Disable',
           url: 'companies/{{record.id}',
           method: :patch,
           authorize: :update?,
           permissions: :admin,
           record_condition: :is_active?
  end

  def self.is_active?(record)
    return record.active?
  end
end