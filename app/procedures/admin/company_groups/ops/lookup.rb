class Admin::CompanyGroups::Ops::Lookup < Admin::Transactions::API

  # step Model(CompanyGroup, :all)
  step Policy::Pundit(Admin::CompanyGroups::Policy, :index?)
  step Resolver::Transactions::Load(klass: Admin::CompanyGroups::Resolver, paginate: false)

end