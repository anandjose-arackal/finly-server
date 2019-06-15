class RulesController < BaseControllers::WebBase



  def create
    @result = Policy::Rules::Create.(current_user, params)
    if @result.success?
      show_op = Policy::Show.new(current_user, params)
      @result = show_op.run
      flash[:success] = "Rule created!"
      respond_to do |format|
        format.js {}
        format.json {}
      end
    else
      flash.now[:error] = @result.messages[:error]
    end
    # redirect_to request.referrer
  end

  def destroy
    @result = Policy::Rules::Destroy.(current_user, params)
    if @result.success?
      show_op = Policy::Show.new(current_user, params)
      @result = show_op.run
      flash[:success] = "Rule destroyed"
      respond_to do |format|
        format.js {}
        format.json {}
      end
    else
      flash.now[:error] = @result.messages[:error]
    end
    # redirect_to request.referrer
  end

end
