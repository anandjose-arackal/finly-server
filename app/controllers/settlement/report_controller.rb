class Settlement::ReportController < ApplicationController

  before_action -> { finly_authorize! :web }

  def pending_index
    @result = Settlement::SReport::Pending::Index.(current_user, params)
    respond
  end

  def create_processing

  end

  def processing_index

  end

  def completed_index

  end

end
