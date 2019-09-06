class Forms::Definitions::Types::BooleanType < Forms::Definitions::Property

  field_type :boolean
  attributes(
      {
          label_positive: "Yes",
          label_negative: "No",
      }
  )

end