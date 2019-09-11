class Transactions::Authorization

  def self.Roles(*list)
    ->(input, options) {Authorize.roles(options, list)}
  end

  class Authorize
    def self.roles(options, list)
      return true if list.blank?

      roles = UserRole::VALUES.keys & list # Find the intersection between all user roles and the list roles
      roles.each do |role|
        return true if options['current_user'].has_role?(role)
      end
      return unauthorized!(options)
    end
  end

  module Transactions::Authorization::DSL

    def self.included(base)
      base.extend ClassMethods
      base.step :authorize_user_presence!
    end

    module ClassMethods
      def schema(&block)
        klass = Class.new(Transactions::Schema)
        klass.instance_eval &block
        step Transactions::Schema::Validate(constant: klass)
      end

      def skip_user_authorization!
        step nil, delete: :authorize_user_presence!
      end

      # Ability to set a different user model user for role verification
      def user_model(model=User)
        @model ||= model
      end
    end

    def unauthorized!(options)
      options["unauthorized"] = true
      false
    end

    def authorize_user_presence!(options)
      return unauthorized! if options['current_user'].nil? or options['current_user'].class.name != user_model

      true
    end

  end

end