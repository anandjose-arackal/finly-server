class Admin::Agreement::Create < Admin::Agreement::Base
  attr_accessor :agreement

  def pre_validate
    super
    if params&.dig(:agreement).blank? or params&.dig(:agreement)&.dig(:content).blank?
      add_message :error, 'Agreement cannot be blank'
    end
  end

  def init
    param = strong_params
    param[:file] = FakeFileIO.new("agreement_#{param[:agreement_type_id]}_v#{param[:version]}.txt",params[:agreement][:content])
    self.agreement = Agreement.new param
  end

  def validate
    if self.agreement.blank?
      add_message :error, 'Agreement details cannot be blank'
      return
    end
    unless self.agreement.valid?
      add_message :error, self.agreement.errors.full_messages
    end
  end

  def process
    self.agreement.save
  end

  def post_process
    if self.agreement.active
      previously_active_agreements = Agreement.active.with_type_id(self.agreement.agreement_type_id).without_id(self.agreement.reload.id)
      previously_active_agreements.update_all active: false
    end
  end

  protected
  def strong_params
    params.require(:agreement).permit(:version, :active, :agreement_type_id)
  end

end