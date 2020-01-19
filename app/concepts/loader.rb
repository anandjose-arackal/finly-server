class Loader

  def self.watch!(&block)
    return unless Rails.env.development?
    
    ActiveSupport::Reloader.to_prepare do
      block.call
    end
  end

end