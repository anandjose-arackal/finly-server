class Settlement::ReportController < ApplicationController

  before_action -> { finly_authorize! :web }

  def pending_index
    @result = Settlement::SReport::Pending::Index.(current_user, params)
    respond
  end

  def init_processing
    @result = Settlement::SReport::Processing::Init.(current_user, params)
    respond
  end

  def create_processing
    @result = Settlement::SReport::Processing::Create.(current_user, params)
    respond
  end

  def processing_index
    @result = Settlement::SReport::Processing::Index.(current_user, params)
    respond
  end

  def completed_index
    @result = Settlement::SReport::Completed::Index.(current_user, params)
    respond
  end

end
