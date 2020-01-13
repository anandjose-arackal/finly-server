class Transactions::Authorization

  def self.Roles(*list)
    Transactions::Task.build id: "authorization.roles" do |context, **|
      Authorize.roles(context, list)
    end
  end

  class Authorize
    extend Dry::Monads[:result]

    def self.roles(context, list)
      return true if list.blank?
      return unauthorized!(input) if context[:current_user].blank?

      user = context[:current_user]
      roles = UserRole::VALUES.keys & list # Find the intersection between all user roles and the list roles
      roles.each do |role|
        role_id = UserRole.id_for(role)
        return true if user.has_policy_role?(role_id)
        return true if role_id == UserRole.id_for(:admin) and user.admin?(RequestStoreUtil.current_app)
      end
      return unauthorized!(input)
    end

    def self.unauthorized!(context)
      context[:"result.authorization"] = Failure("You cannot perform the following action")
      false
    end
  end

  module Transactions::Authorization::DSL

    def self.included(base)
      base.extend ClassMethods
      base.extend Dry::Monads[:result]
      base.send(:step, :authorize_user_presence!)
    end

    module ClassMethods
      def skip_user_authorization!
        step nil, delete: :authorize_user_presence!
      end

      # Ability to set a different user model user for role verification
      def user_model(model = User)
        @model ||= model
      end

      def authorized_roles(*list)
        step Transactions::Authorization::Roles(*list)
      end
    end

    def unauthorized!(context)
      context["result.authorization"] = Failure("You cannot perform the following action")
      false
    end

    def user_model
      self.class.user_model
    end

    def authorize_user_presence!(context, options)
      return true if user_model.nil?
      return unauthorized!(context) if context[:current_user].nil? or options[:current_user].class.name != user_model.name

      true
    end

  end

end