require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      
      source_table = source_options.table_name
      through_table = through_options.table_name
      source_foreign_key = source_options.send(:foreign_key)
      source_primary_key = source_options.send(:primary_key)
      through_foreign_key = through_options.send(:foreign_key)
      through_primary_key = through_options.send(:primary_key)
      
      results = DBConnection.execute(<<-SQL, self.send(through_foreign_key))
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
        ON
          #{through_table}.#{source_foreign_key} =
          #{source_options.table_name}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL
      
      source_options.model_class.parse_all(results).first
    end
  end
end