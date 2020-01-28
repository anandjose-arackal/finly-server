module Forms::Contracts::DSL
  extend ActiveSupport::Concern

  class_methods do
    def contract(user, params = {})
      Forms::Contracts::DSL::Build(self, user: user, params: params)
    end
  end

  def self.Build(api, user:, params:)
    company = user.company
    raise 'Invalid company' unless company.class.name == Company.name
    raise 'Invalid user' unless user.class.name == User.name

    Build.with(api, user: user, params: params)
  end

  module Build
    def self.with(api, user:, params:)
      klass = Class.new(Transactions::Contract) do
        api.sections.each do |section|
          section.entities.each do |entity|
            instance_eval &entity.build
          end
        end
      end
      klass
    end
  end

end