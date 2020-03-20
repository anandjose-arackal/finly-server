class RequestFormatter::ApiParser::FmParser::V1::Users::Update < RequestFormatter::Base

  def process
    self.formatted_request = format_file(__dir__, 'update.yaml.erb', user, params)
  end

end
