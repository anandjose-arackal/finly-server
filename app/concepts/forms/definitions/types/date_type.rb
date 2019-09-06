class Forms::Definitions::Types::DateType < Forms::Definitions::Property

  field_type :date
  hint 'Select Date'

  filters %i(
    lteq
    gteq
    btwn
    eq_days
    lteq_days
    gteq_days
  )

  attributes(
      {
          min_date: nil,
          max_date: nil
      }
  )


end