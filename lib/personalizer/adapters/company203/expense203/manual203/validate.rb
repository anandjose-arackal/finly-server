#class Personalizer::Adapters::Company203::Expense203::Manual203::Create203::Validate < Personalizer::Adapters::Base
#
#  attr_accessor :expense_params, :category_id, :purpose
#
#  def init
#    self.expense_params = op_instance.expense_params
#    self.purpose = self.expense_params[:note]
#  end
#
#  def process
#     if self.purpose.blank?
#        add_message :error, "Expense Purpose can't be blank"
#        return
#     end
#  end
#end