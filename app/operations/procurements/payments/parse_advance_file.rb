class Procurements::Payments::ParseAdvanceFile < Procurements::Payments::Base

  attr_accessor :header, :contents, :file, :payment_mode, :scheduled_at, :policy

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    self.file = params[:file]
    headers = [:purchase_order_id, :advance_amount]
    self.parsed_data = ImportUtil.load_spreadsheet(file, headers,
                                                   {skip_empty_lines: true})
    self.payment_mode = params[:transfer_type]
    self.scheduled_at = params[:scheduled_at]
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)
  end

  def validate

  end

  def process

  end


end