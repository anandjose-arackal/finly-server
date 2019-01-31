class SpecialResponseController < ApplicationController

  # dummy action that just shows the page to upload a file
  def new

  end

  def process_file
    @result = SpecialResponse::Cancel.(current_user, params)
    respond
  end


end