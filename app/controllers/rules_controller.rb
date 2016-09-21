class RulesController < ApplicationController

  before_action :authenticate_user!

  def create
    @result = Policy::Rules::Create.(current_user, params)
    if @result.success?
      flash[:success] = "Rule created!"
      respond_to do |format|
        format.js {}
      end
    else
      flash.now[:error] = @result.messages[:error]
    end
    # redirect_to request.referrer
  end

  def destroy
    @result = Policy::Rules::Destroy.(current_user, params)
    if @result.success?
      flash[:success] = "Rule destroyed."
      respond_to do |format|
        format.js {}
      end
    else
      flash.now[:error] = @result.messages[:error]
    end
    # redirect_to request.referrer
  end



end
