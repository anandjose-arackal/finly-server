class ExportManager::Generator::Erb < ExportManager::Generator::Base

  def self.accept?(format, options)
    return false if options[:file].blank?
    acceptable_format = options[:format]
    (acceptable_format.is_a?(Array) and acceptable_format.include?(format.to_sym)) or (acceptable_format == format.to_sym)
  end


end