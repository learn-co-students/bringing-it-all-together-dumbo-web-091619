class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(attributes)
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def update
    sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
  end

  def save 
    if self.id
      self.update
    else
      sql = <<-SQL
          INSERT INTO dogs (name, breed) 
          VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    attributes = attribue_from_row(row)
    Dog.new(attributes)
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
    row = DB[:conn].execute(sql, id)[0]
    attributes = attribue_from_row(row)
    Dog.new(attributes)
  end

  def self.attribue_from_row(row)
    {
      id: row[0],
      name: row[1],
      breed: row[2]
    }
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog_data)
    else
      attributes = {id: nil, name: name, breed: breed}
      dog = self.create(attributes)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? LIMIT 1
      SQL
    row = DB[:conn].execute(sql, name)[0]
    attributes = attribue_from_row(row)
    Dog.new(attributes)
  end

end