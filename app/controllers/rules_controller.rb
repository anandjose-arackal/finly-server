class RulesController < ApplicationController

  before_action :authenticate_user!

  def create
    create_op = Policy::Rules::Create.new(current_user, params)
    if create_op.run
      flash[:success] = "Rule created!"
    else
      flash.now[:error] = create_op.errors
    end
  end

  def destroy
    destroy_op = Policy::Rules.Destroy,new(current_user, params)
    if destroy_op.run
      flash[:success] = "Rule destroyed."
    else
      flash.now[:error] = create_op.errors
    end
  end



end
