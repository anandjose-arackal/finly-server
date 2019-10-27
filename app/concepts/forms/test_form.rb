module Forms
  class TestForm < API

    model Invoice
    section :header do
      text :name, hint: "Please enter the name of the field", char_limit: 255
      collection :line_items do
        text :item_description, hint: "Please enter the name of the field", char_limit: 255
      end
    end

  end
end