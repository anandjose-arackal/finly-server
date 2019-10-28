Dir["#{Rails.root}/app/concepts/forms/definitions/types/*.rb"].each {|file| load file }
module Forms
  module Definitions
    class Section
      include Registry
      attr_accessor :key, :block, :form

      def initialize(form, key, &block)
        self.form = form
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