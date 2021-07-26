class Masters::RecordLookupController < LookupController

  def route
    params[:route] = "masters.#{params[:master_key]}"
    super
  end

end
