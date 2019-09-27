require_relative "../config/environment.rb"

class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @name, @breed, @id = name, breed, id
    end


    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs 
        ( id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL
       DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed) VALUES
                (?, ?)
            SQL

            sql2 = <<-SQL
                SELECT last_insert_rowid() FROM dogs
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute(sql2)[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(dog_id)
        sql =  <<-SQL
            SELECT * FROM dogs 
            WHERE dogs.id = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, dog_id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs 
        WHERE dogs.name = ? AND dogs.breed = ? 
        LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_info = dog[0]
            dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(dog_name)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE dogs.name = ?
            LIMIT 1
        SQL
        DB[:conn].execute(sql, dog_name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end