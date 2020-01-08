module Forms::Builders::Filters

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def filters(user)
      Forms::Builders::Filters::Build(self, company: user.company, user: user)
    end
  end

  def self.Build(api, company:, user:)
    raise 'Invalid company' unless company.class.name == Company.name
    raise 'Invalid user' unless user.class.name == User.name

    Build.with(api.properties, company, user)
  end

  module Build
    def self.with(properties, company, user)
      response = []

      properties.each do |property|
        if property.association?
          result = Build.with(property.properties, company, user)
          if result.respond_to?(:each)
            response += result
          else
            response << result
          end
        else
          response << property.filter_form
        end
      end
      response
    end
  end

end