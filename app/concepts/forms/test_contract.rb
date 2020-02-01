class Forms::TestContract < Forms::Contracts::Builder

  class Forms::TestContract::Form < Forms::API

    section :header do
      text :name, char_limit: 10, required: true
      # property :profile do
      #   text :employee_id#, char_limit: 10, required: true
      # end
    end

  end

  class Forms::TestContract::Test < Transactions::Contract
    property :first_name
    property :profile do
      property :employee_id
    end
    collection :role_mapping do

    end
    validate :test
    def test
      # debugger
    end
    # validate -> (){puts "Class: #{profile.class}"}
  end


  # form Forms::TestContract::Form
  # property :id
  # property :name, form: {required: false}#, char_limit: 20}
  property :profile, populate_if_empty: UserProfile do
    property :employee_id, form: {required: true, char_limit: 5}
  end

  # collection :name do
  #   property :description
  # end

  # validate :test_id
  #
  # def test_id
  #   debugger
  # end

end