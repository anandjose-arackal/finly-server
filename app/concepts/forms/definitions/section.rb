Dir["#{Rails.root}/app/concepts/forms/definitions/types/*.rb"].each {|file| load file }
module Forms
  module Definitions
    class Section
      include Types::DSL
      attr_accessor :key, :block

      def initialize(key, &block)
        self.key = key
        self.block = block
        instance_eval &block if block.present?
      end

      def section
        key
      end
    end
  end
end