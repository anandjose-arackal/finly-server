class Companies::Actions::Index::Row < ActionManager::API
  scope policy: Companies::Policy, model: Company do
    action :api_request,
           :disable,
           label: 'Disable',
           url: 'companies/{{record.id}',
           method: :patch,
           authorize: :disable?,
           permissions: :admin,
           body: {
             active: false,
           },
           confirmation: "Are you sure you want to disable this entity?"
  end
end
