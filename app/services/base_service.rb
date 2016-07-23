class BaseService
  attr_accessor :errors

  def initialize
    @errors = Array.new
  end

  protected
  def load_view(params)
    debugger
    view = params[:view] || params['view']
    case view
      when 'admin'
        @admin_view = true
      when 'manager'
        @manager_view = true
      when 'finance'
        @finance_view = true
      when 'auditor'
        @auditor_view = true
      else
        @personal_view = true
    end
  end

end