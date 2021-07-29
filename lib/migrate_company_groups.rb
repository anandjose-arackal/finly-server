class MigrateCompanyGroups
  def self.run
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    Company.find_each do |company|
      next if company.group.present?

      group = CompanyGroup.create!(
        name: company.name,
        default_company_id: company.id,
      )

      company.update_columns(group_id: group.id)
    end
  end
end
