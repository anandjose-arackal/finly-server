module Helpers::RequestImpressionHelper

  # included do
  #   around_action :save_request_impression
  # end

  def save_request_impression
    start = Time.now
    RequestImpressions::Create.(request, params)
    begin
      yield
    ensure
      duration = Time.now - start
      RequestImpressions::OnResponse.(duration, response, params)
    end
  end

end