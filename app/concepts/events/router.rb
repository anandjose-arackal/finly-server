class Events::Router < Routers::Base
  Routers::Registry.register :events, self

  allow_multiple_associations!

  def self.draw(&block)
    super
    map.each do |key, routes|
      routes.each do |route|
        klass = route.klass
        options = route.options
        # Its async by default
        sync = options[:sync] || false
        klass.include(Events::Consumer) unless klass.respond_to?(:consumes_event!)
        klass.consumes_event! key, sync: sync
      end
    end
  end

end