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

  # private
  def generate_yaml_params(params)
    yaml_params = params.deep_dup
    temp_holder = {}
    i = 0
    replace_hash_with_keys yaml_params, i, temp_holder
    {params: params, yaml_params: yaml_params, yaml_map: temp_holder}
  end

  def replace_hash_with_keys(params, pos, temp_hash)
    if params.is_a?(Array)
      params.each_with_index do |value, position|
        if [Hash, Array].include? value.class
          replace_hash_with_keys value, pos, temp_hash
        else
          temp_hash[pos] = value
          params[position] = pos
          pos += 1
        end
      end
    elsif params.is_a?(Hash)
      params.each do |key, value|
        if [Hash, Array].include? value.class
          replace_hash_with_keys value, pos, temp_hash
        else
          temp_hash[pos] = value
          params[key] = pos
          pos += 1
        end
      end
    end
  end

end
