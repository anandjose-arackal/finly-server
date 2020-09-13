# The scope is used for defining shared prefixes. This makes managing paths simpler as
# they are grouped together. Scopes accept wildcards ( * )
# scope :companies do
#   The route is used for mapping a path to an associated EventConsumer
#   Routes accept wildcards
#   Route can be defined by
#   1. Passing a block and defining +to+ inside the block
#     route :create do
#       # to Users::Create, sync: true
#       # to Users::Update # Defaults to async
#     end
#   2. By directly passing the list of consumers
#     route 'companies.create', Users::Update, sync: true
#
#   route :create do
#     to is used for defining the EventConsumer. It accepts an option sync: true/false. Sync defaults to false
#     to Users::Create, sync: true
#     to Users::Update # Defaults to async
#   end
# end
# route 'companies.create' do
#   to Users::Create, sync: true
# end
#
# route 'companies.create', Users::Update
Events::Router.draw do

  scope :companies do
    route '*' do
      to Masters::Users::TraitPublisher::CompanyHandler
    end

    route 'create' do

    end
  end

  scope :users do
    route '*' do
      to Masters::Users::TraitPublisher::UserHandler
    end
  end

  scope :user_role_mappings do
    route '*' do
      to Masters::Users::TraitPublisher::UserRoleHandler
    end
  end

  scope :policy_user_roles do
    route '*' do
      to Masters::Users::TraitPublisher::UserRoleHandler
    end
  end

  scope :user_sessions do
    route :create do
      to Masters::Users::TraitPublisher::UserSessionTracker
    end
  end
end