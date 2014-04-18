require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end
    objects
  end
end

class SQLObject < MassObject
  def self.columns
    columns = DBConnection.execute(<<-SQL)
    SELECT
      column_name
    FROM
      USER_TAB_COLUMNS
    WHERE
      table_name = #{self.table_name}
    SQL
    columns.map(&:to_sym)
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    all_hash = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    self.parse_all(all_hash)
  end

  def self.find(id)
    DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
  end

  def attributes
    unless @attributes
      @attributes = {}
      
      self.class.columns.each do |column|
        @attributes[column] = nil
      end
    end
    @attributes
  end

  def insert
    # ...
  end

  def initialize(attr_hash = nil)
    @attributes = attr_hash if attr_hash
    attributes
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    # ...
  end
end
