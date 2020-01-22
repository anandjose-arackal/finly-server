module Forms::Builders::Drop

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def build_drop(company, user)
      Forms::Builders::Drop::Build(self, company: company, user: user)
    end
  end

  def self.Build(api, company:, user:)
    raise 'Invalid company' unless company.class.name == Company.name
    raise 'Invalid user' unless user.class.name == User.name

    Build.with(api, company, user)
  end

  module Build
    def self.with(api, company, user)
      # TODO
    end
  end

end