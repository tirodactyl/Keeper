require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{params.keys.map { |k| "#{k} = ?" }.join(' AND ')}
    SQL
    
    self.parse_all(results)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
