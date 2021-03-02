class Companies::Actions::Index::Row < ActionManager::API
  scope policy: Companies::Policy, model: Company do
    action :api_request,
           :disable,
           label: 'Disable',
           url: 'companies/{{record.id}',
           method: :patch,
           authorize: :disable?,
           permissions: :admin
  end
end
