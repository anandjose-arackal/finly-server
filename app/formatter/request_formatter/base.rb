class RequestFormatter::Base < BaseOperation
  attr_accessor :formatted_request

  def success
    params[:formatted_request] = self.formatted_request
    RequestFormatter::Base::SuccessPresenter.new(user, params, messages)
  end

  def format_file(dir_path, file_path, user, params)
    return nil if params.blank? or file_path.blank?
    path = dir_path.present? ? "#{dir_path}/#{file_path}" : file_path
    yaml_formatter = RequestFormatter::Base::YamlFormatter.new params
    # Set all values with placeholders as YAML does not support many data formats.
    yaml_formatter.generate_yaml_params
    output = YamlUtils.load_yaml_erb(path, {user: user, params: yaml_formatter.yaml_params, yaml_formatter: yaml_formatter})
    # Used for replacing the placeholders with actual values again.
    map = yaml_formatter.process_yaml_output output
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

  # As YAML cannot handle many formats such as files, boolean, multilined strings, we use yamlformatter which replaces all the values in the has with a placeholder.
  # Once the params is restructured using YAML, we replace the original values using YamlFormatter.process_yaml_output.
  # This way YAML can be used to restructure any hash with any format of data
  class RequestFormatter::Base::YamlFormatter
    attr_accessor :params, :placeholder_mapping, :yaml_params, :pos

    PLACEHOLDER_KEY = 'yaml_placeholder_'

    def initialize(params)
      self.params = params
      self.placeholder_mapping = {}
      self.pos = 0
    end

    # Used for replacing the values with placeholders
    def generate_yaml_params
      return nil if self.params.blank?
      self.yaml_params = self.params.deep_dup
      set_placeholders yaml_params, placeholder_mapping
      yaml_params
    end

    # Used for retrieving values from YAML Output using placeholders
    def process_yaml_output(yaml_output)
      if yaml_output.is_a?(Array)
        yaml_output.each_with_index do |value, position|
          puts "Value: #{value}, position: #{position}, Class: #{value.class}"
          if [Hash, Array].include? value.class
            process_yaml_output value
          else
            yaml_output[position] = placeholder_mapping[value]
          end
        end
      elsif yaml_output.is_a?(Hash)
        yaml_output.each do |key, value|
          if [Hash, Array].include? value.class
            process_yaml_output value
          elsif value.is_a?(String) and value.starts_with?(PLACEHOLDER_KEY)
            yaml_output[key] = placeholder_mapping[value]
          end
        end
      end
    end

    def value_for_placeholder(placeholder)
      return nil if placeholder.blank? or self.params.blank? or placeholder_mapping.blank? or yaml_params.blank?
      placeholder_mapping[placeholder]
    end

    protected
    def set_placeholders(items, placeholder_mapping)
      case items.class
        when Array
          when Hash, ActionController::Parameters
      end
      if items.is_a?(Array)
        items.each_with_index do |value, position|
          if [ActionController::Parameters, Hash, Array].include? value.class
            set_placeholders value, placeholder_mapping
          else
            pos = next_pos
            placeholder_mapping["#{PLACEHOLDER_KEY}#{pos}"] = value
            items[position] = "#{PLACEHOLDER_KEY}#{pos}"
          end
        end
      elsif items.is_a?(Hash)
        items.each do |key, value|
          if [ActionController::Parameters, Hash, Array].include? value.class
            set_placeholders value, placeholder_mapping
          else
            pos = next_pos
            placeholder_mapping["#{PLACEHOLDER_KEY}#{pos}"] = value
            items[key] = "#{PLACEHOLDER_KEY}#{pos}"
          end
        end
      end
    end

    def next_pos
      self.pos += 1
      self.pos
    end
  end

end
