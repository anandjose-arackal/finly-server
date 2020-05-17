require 'disposable/twin/parent'
class Forms::TestContract < Forms::Generators::Contracts::API

  class Forms::TestContract::Form < Forms::API

    section :header do
      text :name, maximum: 10, required: true
      # property :profile do
      #   text :employee_id#, maximum: 10, required: true
      # end
    end

  end

  class Forms::TestContract::Test < Reform::Form
    # feature Disposable::Twin::Parent

    property :first_name
    property :profile do
      property :employee_id#, deserializer: -> (input, represented, *args) {debugger}

      validate :test_em_id

      def test_em_id
        # debugger
      end

    end
    # property :t_bag
    # collection :role_mapping, deserializer: -> (input, represented, **) { debugger } do
    #
    # end
    validate :test

    def test
      puts "Test"
      # debugger
    end

    # def deserialize!(params)
    #   puts "Deserialize"
    #   debugger
    #   # debugger
    # end
    # validate -> (){puts "Class: #{profile.class}"}
  end


  # form Forms::TestContract::Form
  # property :id
  # property :name, form: {required: false}#, maximum: 20}
  property :profile, populate_if_empty: UserProfile do
    property :employee_id, form: {required: true, maximum: 5}
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