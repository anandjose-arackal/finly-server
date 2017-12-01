class FinlyCollectController < ApplicationController

  def notify
    @result = AccountManager::Collect::CollectRouter.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end
