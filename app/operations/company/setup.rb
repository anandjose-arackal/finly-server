class Company::Setup

  attr_accessor :company

  def initialize(company)
    self.company = company
  end

  def self.call(company)
    new(company).run
  end

  def run
    add_export_templates
  end

  def add_export_templates
    ExportManager::TemplateMaster.subscribers.each do |_, list|
      list.each do |master|
        ExportTemplateNew.create!(**master.build, company_id: company.id)
      end
    end
  end

end