class Procure::PaymentsController < ApplicationController
  before_action -> {finly_authorize! :web}

  def show
    @result = Procurements::Payments::Show.(current_user, params)
    respond
  end

  # this operation will create an advance payment inside a particular Procurement
  def create
    @result = Procurements::Payments::Create.(current_user, params)
    respond # todo - change this in case it is just a success / failure
  end

  def bulk_create_advance
    @result = Procurements::Payments::BulkCreateAdvance.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json {
          render 'bulk_create_advance_success'
        }
      end
    else
      respond_to do |format|
        format.json {
          render 'bulk_create_advance_failure'
        }
      end
    end
  end
end