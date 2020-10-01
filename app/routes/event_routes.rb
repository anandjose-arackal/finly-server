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
    route :create do

    end
  end

  scope :items do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :purchase_requests do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :purchase_orders do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :invoices do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :payments do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :bbps_bills do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :vendors do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :items do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :categories do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :policies do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :departments do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :locations do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :cost_centers do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :agreements do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :bbps_biller_subscriptions do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end

  scope :users do
    route '*' do
      to SearchIndex::EventListeners::RecordChange
    end
  end
end