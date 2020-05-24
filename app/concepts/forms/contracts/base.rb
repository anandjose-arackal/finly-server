class Forms::Contracts::Base < Reform::Form

  def validate(input)
    # Fixme : This a workaround for setting root, parent and input of the contract. Need a better way
    RequestStore[:contract_input] = input #if RequestStore[:contract_input].nil?
    RequestStore[:contract_root] = self #if RequestStore[:contract_root].nil?
    RequestStore[:contract_parent] = self
    result = super(input)
    RequestStore[:contract_root] = nil
    RequestStore[:contract_input] = nil
    RequestStore[:contract_parent] = nil
    result
  end

end