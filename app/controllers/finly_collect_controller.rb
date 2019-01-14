class FinlyCollectController < BaseControllers::PublicBase

  # before_action { authorize_ip(Finly::SecureStorage::Connector.read('core/finly_collect')&.dig('incoming', 'whitelisted_ip')) }
  # http_basic_authenticate_with :name => Finly::SecureStorage::Connector.read('core/finly_collect')&.dig('incoming', 'username'),
  #                              :password => Finly::SecureStorage::Connector.read('core/finly_collect')&.dig('incoming', 'password')

  def notify
    AccountManager::Collect::CollectRouter.(current_user, params)
    # if @result.success?
    respond response: :success
    # else
    #   respond response: :failure, message: @result.messages[:error]
    # end
  end

end
