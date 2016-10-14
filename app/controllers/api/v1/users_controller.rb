class  Api::V1::UsersController < Api::V1::BaseApiController
  protect_from_forgery with: :null_session

  allow_oauth!
  before_action :authenticate_user!

  respond_to :json

  def index
    @result = User::Index.(current_user, params)
    respond
  end

  def show
    @result = User::Show.(current_user, params)

    ## Jugaad
    if @result.success? and @result.selected_user.cards.present?
      @result.selected_user.cards.first.balance = 500
    end
    ## Jugaad end
    respond
  end

end