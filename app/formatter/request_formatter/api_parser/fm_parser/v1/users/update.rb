class RequestFormatter::ApiParser::FmParser::V1::Users::Update < RequestFormatter::Base

  def process
    params[:gender] = ((['male', 'female'].include? (params[:gender].downcase)) ? params[:gender].downcase.split("").first : nil )
    self.formatted_request = format_file(__dir__, 'update.yaml.erb', user, params)
  end

end
