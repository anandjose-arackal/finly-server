module Versionable
  extend ActiveSupport::Concern

  included do

  end

  def version_configuration

  end

  def create_version
    config = self.version_configuration || {}
    if self.version_link.blank?
      self.version_link = self.class.generate_version_link
    end
    self.deep_clone config do |original, kopy|
      if kopy.respond_to?(:is_versionable?) and kopy.is_versionable?
        original.version_id += 1
        kopy.version_latest = false
      end
    end
  end

  def is_versionable?
    true
  end

  class_methods do

    def generate_version_link

    end

  end

end