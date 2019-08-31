module Documentable
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    def master(master = NoObject)
      @master = master unless master == NoObject
      @master
    end
  end

end