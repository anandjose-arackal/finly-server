class ExpenseTypesConfigurationController < ApplicationController

  def show
    @result = ExpenseTypes::Show.(user, params)
    respond
  end

  def update
    case params[:type]
      when '1'
        @result = ExpenseTypes::ExDistance::Update.(user, params)
      when '2'
        @result = ExpenseTypes::ExTime::Update.(user, params)
      when '3'
        @result = ExpenseTypes::ExPerDiem::Update.(user, params)
      else
        # do nothing
    end
    respond
  end

  def index

  end

end
