class Company::Setup < Transactions::API

  attr_accessor :company

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
            existing_template.update!(**master.build)
          end
        else
          ExportTemplateNew.create!(**master.build, company_id: self.company.id)
        end
      end
    end
  end
end
