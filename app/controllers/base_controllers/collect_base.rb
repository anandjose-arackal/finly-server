class BaseControllers::CollectBase < ApplicationController

  before_action do
    if FinlyCollect.config.blank? or FinlyCollect.read(:incoming, :whitelisted_ip).blank? or
        FinlyCollect.read(:incoming, :username).blank? or FinlyCollect.read(:incoming, :password).blank?
      head 422
    end
  end
  before_action { authorize_ip(FinlyCollect.read(:incoming, :whitelisted_ip)) }
  http_basic_authenticate_with :name => FinlyCollect.read(:incoming, :username),
                               :password => FinlyCollect.read(:incoming, :password)

  def authentication_scope
    nil
  end

end
