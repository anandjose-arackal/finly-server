module TaskManager::Actions::FileManager::Validations

  def self.included(base)
    base.validate :file_manager_validation
  end

  def file_manager_validation
    return if file_manager_actions.blank?
    file_manager_actions.each do |file_manager_action|
      next if file_manager_action.export_template_id.nil?
      template = ExportTemplate.find file_manager_action.export_template_id
      if template.personal and not template.created_by_user_id == user_id
        errors.add :template, 'not found'
        return
      elsif !template.personal and not template.company_id == company_id
        errors.add :template, 'not found'
        return
      end
      unless template.model_class == self.model_class
        errors.add :document, 'mismatch with export template'
        return
      end
    end
  end

end