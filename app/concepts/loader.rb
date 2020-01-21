class Loader

  def self.watch!(dir: nil, path: nil, &block)
    return unless Rails.env.development?

    ActiveSupport::Reloader.to_prepare do
      block.call if block_given?
      Dir.glob(Rails.root.join.dir).each { |f| load(f) } if dir
      load Rails.root.join.path if path
    end
  end

end