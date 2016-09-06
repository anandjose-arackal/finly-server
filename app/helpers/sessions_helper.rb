module SessionsHelper

  # returns the company that the current user is a part of
  def current_company
    return nil unless current_user.present?
    @current_company ||= current_user.company
  end

  # stores the location of the page requested by the user that can only be accessed by logging in
  def store_request_url
    session[:forwarding_url] = request.url if request.get?
  end

end
