class RequestFormatter::Api::Fm::V1::Users::Create < RequestFormatter::Base

  def process
    self.formatted_request = format_file(__dir__, 'create.yaml.erb', user, params)
  end

end