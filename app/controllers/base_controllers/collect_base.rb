class BaseControllers::CollectBase < ApplicationController

  before_action { authorize_ip(Finly::SecureStorage::Connector.read('core/finly_collect')&.dig('incoming', 'whitelisted_ip')) }
  http_basic_authenticate_with :name => Finly::SecureStorage::Connector.read('core/finly_collect')&.dig('incoming', 'username'),
                               :password => Finly::SecureStorage::Connector.read('core/finly_collect')&.dig('incoming', 'password')

end
