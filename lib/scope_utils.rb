class ScopeUtils

  def self.fix_for_scoping(params, key, type)
    case type
      when :array
        params[key] = [params[key]] if params.present? and params[key].present? and not params[key].is_a?(Array)
    end
  end

end