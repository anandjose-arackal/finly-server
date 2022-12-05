class ImportJobs::Router < Routers::Base
  Routers::Registry.register :import_jobs, self

  def self.klass(route)
    ImportJobs::Router.map[route]&.first&.klass
  end
end
