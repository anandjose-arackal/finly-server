class Procure::PurchaseRequestsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def index

  end
end