module Forms
  class TestForm < API

    model Invoice
    section :header do
      text :name, hint: "Please enter the name of the field", char_limit: 255
    end

  end
end