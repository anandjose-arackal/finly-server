class RequestFormatter::Api::Cards::V1::Users::UpdateRole < RequestFormatter::Base

  def process
    self.formatted_request = format_file(__dir__, 'update_role.yaml.erb', user, params)
  end

end