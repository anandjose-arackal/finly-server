class Forms::Definitions::Types::SequenceType < Forms::Definitions::Property

  field_type :sequence
  hint 'Auto-generated'
  attributes(
      {
          override: true
      }
  )
  options(
      {
          sequence_key: nil
      }
  )

end