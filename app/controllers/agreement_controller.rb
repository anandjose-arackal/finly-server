class AgreementController < ApplicationController

  def index
    @result = Agreements::Index.(nil, params)
    respond
  end

end
