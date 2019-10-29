Dir["#{Rails.root}/app/concepts/forms/definitions/types/*.rb"].each {|file| load file }
module Forms
  module Definitions
    class Section
      include Registry
      attr_accessor :name, :block, :form

      def initialize(form, name, &block)
        self.form = form
        self.name = name
        self.block = block
        instance_eval &block if block.present?
      end

      def section
        name
      end
    end
  end
end