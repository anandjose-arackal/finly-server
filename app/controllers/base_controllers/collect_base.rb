class BaseControllers::CollectBase < ApplicationController

  before_action do
    next 422 unless FinlyCollect.config.blank?
    next 422 unless FinlyCollect.read('incoming', 'whitelisted_ip').present?
    next 422 unless FinlyCollect.read('incoming', 'username').present?
    next 422 unless FinlyCollect.read('incoming', 'password').present?
  end
  before_action { authorize_ip(FinlyCollect.read('incoming', 'whitelisted_ip')) }
  http_basic_authenticate_with :name => FinlyCollect.read('incoming', 'username'),
                               :password => FinlyCollect.read('incoming', 'password')

  def authentication_scope
    nil
  end

end
