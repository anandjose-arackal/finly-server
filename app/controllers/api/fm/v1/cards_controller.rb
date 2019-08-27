class Api::Fm::V1::CardsController < ApiApplicationController


  def index
    @result = Card::Index.(current_user, params)
    respond
  end

  def show
    @result = Card::Show.(current_user, params)
    respond
  end

  # retrieves card transactions by card_id
  def transactions
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

  def update_status
    params[:validate_password] = false
    status_type = params&.dig(:status)&.to_i rescue -1
    case status_type
      when User::PrepaidCard::Base::STATUS[:block]
        # Block = 0
        @result = User::PrepaidCard::Block.(current_user, params)
      when User::PrepaidCard::Base::STATUS[:unblock]
        # Unblock = 1
        @result = User::PrepaidCard::Unblock.(current_user, params)
    end
    if @result.nil?
      respond response: :failure, message: 'Invalid Status'
    else
      respond response: (@result&.success? ? :success : :failure)
    end
  end


  # def update_restrictions
  #   @result = Card::Restriction::Update.(current_user, params)
  #   respond response: (@result&.success? ? :success : :failure)
  # end
  #
  # def assign
  #   # @result
  #   # respond response: (@result&.success? ? :success : :failure)
  # end

end
