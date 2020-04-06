module Exposures::PreLoader
  extend ActiveSupport::Concern

  def self.includes_for(exposure_klass, *fields)
    config = []
    fields.each do |field|
      includes = exposure_klass.attributes[field]&.includes
      next unless includes.present?

      config += includes
    end
    config.uniq
  end

  # Pre-loads(includes) the associated records to prevent N+1
  def self.preload!(exposure_klass, associations, *fields)
    incl = includes_for(exposure_klass, *fields)
    associations.includes(incl)
  end

  class_methods do
    def includes_for(*fields)
      Exposures::PreLoader.includes_for(self, *fields)
    end

    def preload!(associations, *fields)
      Exposures::PreLoader.preload!(self, associations, *fields)
    end
  end

end
