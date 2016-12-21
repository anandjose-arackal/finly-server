class RegistrationsController < ApplicationController


  def preview
    @result = Company::Preview.(nil, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

end
