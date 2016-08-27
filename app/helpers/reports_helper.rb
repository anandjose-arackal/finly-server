module ReportsHelper
  def formatted_violations(violations)
    messages = ""
    if violations.blank?
      return
    end
    violations.each do |k, v|
      if v.is_a?(Array)
        v.each do |message|
          messages += message + "<br /> <br />"
        end
      else
        messages += v + "<br /> <br />"
      end
    end
    messages
  end
end
