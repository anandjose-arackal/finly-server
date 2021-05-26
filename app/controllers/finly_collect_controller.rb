class FinlyCollectController < BaseControllers::CollectBase

  def notify
    ActsAsTenant.without_tenant do
      AccountManager::Collect::CollectRouter.(current_user, params)
    end
    # if @result.success?
    respond response: :success
    # else
    #   respond response: :failure, message: @result.messages[:error]
    # end
  end

end