class RequestFormatter::Base < BaseOperation
  attr_accessor :formatted_request

  def success
    params[:formatted_request] = self.formatted_request
    RequestFormatter::Base::SuccessPresenter.new(user, params, messages)
  end

  def format_file(dir_path, file_path, user, params)
    return nil if params.blank? or file_path.blank?
    path = dir_path.present? ? "#{dir_path}/#{file_path}" : file_path
    map = YamlUtils.load_yaml_erb(path, {user: user, params: params})
    # Was crashing when note had a new line break. Fix was to remove it from YAML and add it here
    map['expense']['note'] = params[:note] if map.dig('expense') and params.dig(:note)
    Formatter.remove_blanks map
    Formatter.symbolize_hash_keys map
    map
  end

  class RequestFormatter::Base::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :formatted_request

    def init
      return if self.params.blank?
      self.formatted_request = self.params[:formatted_request]
    end

  end

end
