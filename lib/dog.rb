class Dog
    attr_accessor :name, :breed, :id
    def initialize(id: nil,name:,breed:)
        @id = id
        @name = name
        @breed = breed
    end
    
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
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
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]   
        end
        self
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name,breed: breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql,id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        AND breed = ?
        SQL
        new_dog = DB[:conn].execute(sql, name,breed)

        if !new_dog.empty?
            dog = new_dog[0]
            # new_name = new_dog[1]
            # new_breed = new_dog[2]
            new_dog = Dog.new(id:dog[0], name: dog[1], breed: dog[2])
        else
            new_dog = self.create(name:name, breed:breed)
        end  
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?,
        breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end