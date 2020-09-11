Events::Router.draw do

  route 'companies.*' do
    to Masters::Users::TraitPublisher::CompanyHandler
  end

  route 'users.*' do
    to Masters::Users::TraitPublisher::UserHandler
  end

  route 'user_role_mappings.*' do
    to Masters::Users::TraitPublisher::UserRoleHandler
  end

  route 'policy_user_roles.*' do
    to Masters::Users::TraitPublisher::UserRoleHandler
  end

  route 'user_sessions.create' do
    to Masters::Users::TraitPublisher::UserSessionTracker
  end

  # route 'companies.create' do
  #   to Users::Create, sync: true
  # end

  # route 'companies.create', Users::Update

end