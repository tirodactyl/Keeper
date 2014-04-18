require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
require 'debugger'

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
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL
    columns = results.first.map { |column| column.first.to_sym }
    
    columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
      
      define_method("#{column}=") do |new_val|
        self.attributes[column] = new_val
      end
    end
    
    columns
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
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
      LIMIT
        1
    SQL
    self.parse_all(results).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    DBConnection.execute(<<-SQL, *attributes.values)
      INSERT INTO
        #{self.class.table_name} (#{self.attributes.keys.join(', ')})
      VALUES
        (#{self.attributes.keys.map {'?'}.join(', ')})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(attr_hash = nil)
    if attr_hash
      attr_hash.each do |k, v|
        column = k.to_sym
        if self.class.columns.include?(column)
          self.send("#{column}=", v)
        end
      end
    end
  end

  def save
    if self.class.find(self.id)
      update
    else
      insert
    end
  end

  def update
    DBConnection.execute(<<-SQL, *attributes.values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{ self.attributes.keys.map { |k| "#{k} = ?" }.join(', ') }
      WHERE
        id = ?
    SQL
  end

  def attribute_values
    @attributes.values
  end
end
