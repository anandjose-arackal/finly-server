Events::Router.draw do

  scope :companies do
    route 'create' do
      # to Users::Create, sync: true
      # to Users::Update # Defaults to async
    end
  end

  # route 'companies.create' do
  #   to Users::Create, sync: true
  # end
  #
  # route 'companies.create', Users::Update

end