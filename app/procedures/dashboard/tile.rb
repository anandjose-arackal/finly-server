class Dashboard::Tile

  attr_accessor :title, :options

  def initialize(title, options)
    self.title = title
    self.options = options
  end

  def build(card, options)
    filter = build_filter(card, params)
    records = Resolver::Router.dispatch(card.resolver, current_user: options[:current_user], params: options[:params])
    path = build_path(card, filters)
    {
        title: self.title,
        count: records.count
    }
  end

  def build_filter(card, params)

  end

end