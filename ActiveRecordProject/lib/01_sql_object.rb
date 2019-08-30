require "byebug"
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns
      return @columns
    else 
    arr = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    
    @columns = arr[0].map{ |ele| ele.to_sym }
    end 
  end

  def self.finalize!
      self.columns.each do |column|
          define_method(column) do  
            #debugger
             self.attributes[column] 
          end  
           define_method("#{column}=") do |value| 
           #debugger
            self.attributes[column] = value #= value 
          end  
      end
  end


  def self.table_name=(table_name)
    @table_name = table_name
    #what am i setting to table name??
  end

  def self.table_name
   if @table_name
    return @table_name
   else 
    @table_name = self.to_s.tableize
   end   
  end

  def self.all
    arr = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(arr)
  end

  def self.parse_all(results)
    arr = []
    results.each do |result|
      new_model = self.new(result) #= ### 
      arr << new_model  
    end 
    arr 
  end

  def self.find(id)
   find_answer = DBConnection.execute(<<-SQL)
    SELECT
      * 
    FROM
      #{self.table_name}
    WHERE
      id = #{id}
    SQL
    if find_answer.empty? 
      nil
    else
      self.new(find_answer)
    end 
  end

  def initialize(params = {})
  
    params.each do |attr_name, value|
       column = attr_name.to_sym  
       raise "unknown attribute '#{column}'" if !self.class.columns.include?(column)
       self.send("#{column}=", value)
    end 
      #self.columns 

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values 
  end

  def insert
    col_names = @columns.join(",")
    question_marks = []
      col_names.length.times do 
        question_marks << "?"
      end 
    
    DBConnection.execute(<<-SQL, self.attribute_values)
    INSERT INTO 
      #{self.table_name} #{col_names}
    VALUES 
    SQL

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
