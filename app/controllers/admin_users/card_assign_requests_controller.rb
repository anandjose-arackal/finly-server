class AdminUsers::CardAssignRequestsController < ApplicationController

  before_action -> { doorkeeper_authorize! :admin }

  def index

  end

  def approve

  end

  def reject

  end

  def mark_as_assigned

  end

  def mark_as_assigned_upgraded

  end

end
