module Forms::Generators::Filters::ModelHelpers::Form

  def filters
    Forms::Generators::Filters::ModelHelpers::Form::Build(self, company: company)
  end

  def self.Build(api, company:)
    raise 'Invalid company' unless company.class.name == Company.name

    Build.with(api.sections, company)
  end

  module Build
    def self.with(entities, company)
      response = []

      entities.each do |entity|
        if entity.entities.present?
          result = Build.with(entity.entities, company)
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