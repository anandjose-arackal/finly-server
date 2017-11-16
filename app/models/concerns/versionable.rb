module Versionable
  extend ActiveSupport::Concern

  def version_configuration
    {include: []}
  end

  def create_version
    config = self.version_configuration || {}
    self.deep_clone config
  end

  def is_versionable?
    true
  end

end