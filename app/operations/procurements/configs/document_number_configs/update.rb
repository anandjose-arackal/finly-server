class Procurements::Configs::DocumentNumberConfigs::Update < Procurements::Configs::DocumentNumberConfigs::Base

  attr_accessor :config, :config_params

  def init
    purpose_id = Purpose.id_for(:vendor_payments) # being picked directly as the operation is scoped
    config_type_id = DocumentNumberConfigType.id_for(params[:document_type])
    self.config = user.company.document_number_configs.with_purpose_id(purpose_id).with_config_type_id(config_type_id).first
    self.config_params = document_number_configuration_params
  end

  def validate
    if self.config.blank?
      add_message :error, "Document number configuration not found"
    end
  end

  def process
    unless self.config.update(self.config_params)
      add_message :error, self.config.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Document Number Updated"
  end

  private

  def document_number_configuration_params
    params.require(:document_number_config).permit(:prefix, :sequence_start)
  end
end