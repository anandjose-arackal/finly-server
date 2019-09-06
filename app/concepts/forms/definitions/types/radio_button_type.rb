class Forms::Definitions::Types::RadioButtonType < Forms::Definitions::Property

  field_type :radio_button
  consumes_choices!
  options(
      {
          min_items: 1,
          max_items: 5
      }
  )

end