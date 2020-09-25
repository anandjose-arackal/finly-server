class HomeController < BaseControllers::PublicBase
  layout :resolve_layout

  # before_action :check_first_login

  def index
    render json: VpRecordsIndex.index.search(params["q"], filters: "(record_type = purchase_requests AND collaborators_ids = 18968) OR (record_type = purchase_orders AND collaborators_ids = 18968) OR (record_type = invoices AND collaborators_ids = 18968) OR (record_type = payment_tickets AND collaborators_ids = 18968) OR (record_type = vendors AND collaborators_ids = 18968) OR (record_type = items)")
    # if signed_in?
    #   render 'index'
    # else
    #   render 'welcome'
    # end
  end

  def landing

  end

  def resources

  end

  def welcome
    if logged_in?
      redirect_to root_path
    end
  end

  def about
  end

  private


  def resolve_layout
    case action_name
    when "index"
      if logged_in?
        "backbone"
      else
        "static"
      end
    when "about", "resources"
      "static"
    when "landing"
      'landing'
    else
      "application"
    end
  end
end
