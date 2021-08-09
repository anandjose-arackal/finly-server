class Masters::RecordFiltersController < FiltersController
  layout 'trailblazers'

  def show
    params[:route] = "masters.#{params[:master_key]}"
    super
  end

  def choices
    params[:route] = "masters.#{params[:master_key]}"
    super
  end

end
