class Admin::CompanyGroups::FilterConfig < Filters::API
  index_builder Admin::CompanyGroups::Ops::Index

  user_model AdminUser

  attribute :name, label: 'Name', type: :text, simple: true
  attribute :subdomain, label: 'Subdomain', type: :text, simple: true
end