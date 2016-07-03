class BaseService
  attr_accessor :errors

  def initialize
    @errors = Array.new
  end

  protected
  def load_view(params)
    view = params[:view]
    if view == 'admin'
      @admin_view = true
    elsif view == 'manager'
      @manager_view = true
    elsif view == 'finance'
      @finance_view = true
    elsif view == 'auditor'
      @auditor_view = true
    else
      @personal_view = true
    end
  end
end