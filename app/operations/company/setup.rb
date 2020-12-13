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
        master.create_or_update_template!(self.company)
      end
    end
  end
end
