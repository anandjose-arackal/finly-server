class FinlyCollect

  def self.read(*path)
    config = self.config
    return nil unless config.present?

    config.dig(*path)
  end

  def self.config
    if File.exists?("#{Rails.root}/config/finly_collect.yml")
      return Rails.application.config_for(:finly_collect)
    end

    nil
  end

end