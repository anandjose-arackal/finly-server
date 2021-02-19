class Companies::Action < ActionManager::API
  scope policy: Companies::Policy, model: Company do
    scope row: true do
    action :api_request,
           :disable,
           label: 'Disable',
           url: 'companies/{{record.id}',
           method: :patch,
           authorize: :update?,
           permissions: :admin
    end
  end
end