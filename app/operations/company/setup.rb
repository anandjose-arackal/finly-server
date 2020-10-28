class Company::Setup < Transactions::API

  attr_accessor :company

  skip_user_authorization!

  step :initialize!

  step :add_export_templates!

  def initialize!(options, **)
    self.company = options[:company]
  end

  def add_export_templates!(options, **)
    ExportManager::TemplateMaster.subscribers.each do |_, list|
      list.each do |master|
        existing_template = ExportTemplateNew.where(master: master.to_s, company_id: self.company.id).first
        if existing_template.present?
          unless existing_template.modified
            existing_template.role_mappings.destroy_all
            data = master.build
            user_roles = data.delete(:user_roles)
            existing_template.update!(**data)
            existing_template.role_mappings.create!(user_roles)
          end
        else
          data = master.build
          user_roles = data.delete(:user_roles)
          export_template = ExportTemplateNew.create!(**data, company_id: self.company.id)
          export_template.role_mappings.create!(user_roles)
        end
      end
    end
  end
end
