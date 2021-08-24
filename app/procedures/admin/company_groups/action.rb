class Admin::CompanyGroups::Action < ActionManager::API

  scope policy: Admin::CompanyGroups::Policy, model: CompanyGroup do
    action :template,
           :create,
           permissions: [:admin],
           format: 'primary',
           label: 'Create Organization',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           function: "organization_create"
  end

end