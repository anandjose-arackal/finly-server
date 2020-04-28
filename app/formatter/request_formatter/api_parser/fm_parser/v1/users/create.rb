class RequestFormatter::ApiParser::FmParser::V1::Users::Create < RequestFormatter::Base
  def process
    if params[:gender].present?
      if (['male', 'female'].include? (params[:gender].downcase) )
        params[:gender] = params[:gender].downcase.split("").first
      else
        " "
      end
    end
    self.formatted_request = format_file(__dir__, 'create.yaml.erb', user, params)
  end

end