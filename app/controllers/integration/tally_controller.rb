class Integration::TallyController < ApplicationController

  before_action :set_tokens_in_header
  before_action -> { finly_authorize! :web}

  def vouchers
    @result = Integrations::Tally::Vouchers.(current_user, params)
    respond
  end

end
