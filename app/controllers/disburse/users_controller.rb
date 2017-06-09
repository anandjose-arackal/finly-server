class Disburse::UsersController < ApplicationController
  def create
    @result = Users::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end