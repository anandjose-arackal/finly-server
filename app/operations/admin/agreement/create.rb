class Admin::Agreement::Create < Admin::Agreement::Base
  attr_accessor :agreement

  def pre_validate
    if params&.dig(:agreement).blank?
      add_message :error, 'Agreement Details cannot be blank'
    end
  end

  def init
    param = strong_params
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

  protected
  def strong_params
    params.require(:agreement).permit(:file, :version, :active, :agreement_type_id)
  end

end