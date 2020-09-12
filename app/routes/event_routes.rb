Events::Router.draw do

  scope 'companies' do
    route '*' do
      to Masters::Users::TraitPublisher::CompanyHandler
    end
  end

  scope 'users' do
    route '*' do
      to Masters::Users::TraitPublisher::UserHandler
    end
  end

  scope 'user_role_mappings' do
    route '*' do
      to Masters::Users::TraitPublisher::UserRoleHandler
    end
  end

  scope 'policy_user_roles' do
    route '*' do
      to Masters::Users::TraitPublisher::UserRoleHandler
    end
  end

  scope 'user_sessions' do
    route 'create' do
      to Masters::Users::TraitPublisher::UserSessionTracker
    end
  end

  # route 'companies.create' do
  #   to Users::Create, sync: true
  # end

  # route 'companies.create', Users::Update

end