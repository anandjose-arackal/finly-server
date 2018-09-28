class Personalizer::Adapters::Company114::User114::Team114::Review114::NextReviewer114::PostProcess < Personalizer::Adapters::Base

  def process
    obj = self.op_instance.obj
    role_id = self.op_instance.role_id
    response = self.op_instance.response

    pravin_joshi = User.find_by_email('ppjoshi@metalmanauto.com')
    shrikant_mundada = User.find_by_email('sgmundada@metalmanauto.com')


    if (obj.is_a?(MoneyRequest) or obj.is_a?(TravelRequest)) and role_id == UserRole.id_for(:manager) and response == pravin_joshi
      self.op_instance.response = shrikant_mundada
    end
  end

end