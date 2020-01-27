module Forms::Filters::Builder

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def filters(user)
      Forms::Filters::Builder::Build(self, company: user.company, user: user)
    end
  end

  def self.Build(api, company:, user:)
    raise 'Invalid company' unless company.class.name == Company.name
    raise 'Invalid user' unless user.class.name == User.name

    Build.with(api.sections, company, user)
  end

  module Build
    # def self.with(entities, company, user, prefix: nil)
    #   response = []
    #
    #   entities.each do |entity|
    #     if entity.entities.present?
    #       filter_key = nil
    #       unless entity.class <= Forms::Entity::Section
    #         filter_key = entity.field_key
    #         filter_key = "#{prefix}_#{filter_key}" if prefix
    #       end
    #       result = Build.with(entity.entities, company, user, prefix: filter_key)
    #       if result.respond_to?(:each)
    #         response += result
    #       else
    #         response << result
    #       end
    #     else
    #       response << entity.filter_form(prefix: prefix)
    #     end
    #   end
    #   response
    # end

    def self.with(entities, company, user)
      response = []

      entities.each do |entity|
        if entity.entities.present?
          result = Build.with(entity.entities, company, user)
          if result.respond_to?(:each)
            response += result
          else
            response << result
          end
        else
          response << entity.filter_form
        end
      end
      response
    end
  end

end