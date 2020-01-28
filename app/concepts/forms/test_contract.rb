class Forms::TestContract < Forms::Contracts::Builder

  class Forms::TestContract::Form < Forms::API

    section :header do
      text :name, char_limit: 10, required: true
    end

  end

  class Forms::TestContract::Test < Transactions::Contract
    property :first_name
    property :profile do
      property :employee_id
      validate -> {debugger}
    end
  end


  form Forms::TestContract::Form
  # property :id
  property :name, form: {required: false}#, char_limit: 20}
  # collection :name do
  #   property :description
  # end

  # validate :test_id
  #
  # def test_id
  #   debugger
  # end

end