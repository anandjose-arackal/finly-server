class RequestFormatter::Base < BaseOperation

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

end
