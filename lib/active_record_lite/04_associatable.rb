require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelize,
      primary_key: :id
    }
    options = defaults.merge(options)
    self.foreign_key = options[:foreign_key]
    self.class_name = options[:class_name]
    self.primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    defaults = {
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      class_name: name.to_s.camelize.singularize,
      primary_key: :id
    }
    options = defaults.merge(options)
    self.foreign_key = options[:foreign_key]
    self.class_name = options[:class_name]
    self.primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)
    
    define_method(name) do
      pk = self.class.assoc_options[name].send(:primary_key)
      m_class = self.class.assoc_options[name].model_class
      m_class.where(pk => id).first
    end
  end

  def has_many(name, options = {})
    assoc_options[name] = HasManyOptions.new(name, self, options)
    
    define_method(name) do
      fk = self.class.assoc_options[name].send(:foreign_key)
      m_class = self.class.assoc_options[name].model_class
      m_class.where(fk => id)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
