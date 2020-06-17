class Dashboard::Tile

  attr_accessor :title, :options, :filter_status, :filter_created_by

  def initialize(title, options)
    self.title = title
    self.options = options
    self.options.each_pair do |key, value|
      self.send("#{key}=", value)
    end
  end

end