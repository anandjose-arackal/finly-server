class Personalizer::Adapters::Company168::BankTransfer168::PaymentRequest168::Beneficiary168::CreateBeneficiaryTicket168::Validate < Personalizer::Adapters::Base
  attr_accessor :payments_attributes, :custom_fields

  def init
    self.payments_attributes= self.op_instance.payments_attributes.first
  end

  def validate
    custom_field_id = current_company.field_configurations.non_deleted.find_by(field_key: 'sub_order_id')&.id
    self.custom_fields = self.payments_attributes[:custom_fields][custom_field_id.to_s] rescue ""
     if custom_fields.blank? || custom_fields&.match?(/^.{8,12}$/) != true
       add_message :error, "Suborder ID must have 8-12 Characters"
     end
  end

end