require 'sqlite3'

DB_PATH = "./db/library.db"

def seed!
  db = SQLite3::Database.new(DB_PATH)

  puts "🧹 Dropping old tables..."
  drop_tables(db)

  puts "🧱 Creating tables..."
  create_tables(db)

  puts "📚 Seeding books..."
  seed_books(db)

  puts "✅ Seeding complete!"
end

def drop_tables(db)
  db.execute("DROP TABLE IF EXISTS users")
  db.execute("DROP TABLE IF EXISTS books")
  db.execute("DROP TABLE IF EXISTS reading_lists")
end

def create_tables(db)
  db.execute <<-SQL
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      password TEXT
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE books (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      author TEXT,
      description TEXT
    );
  SQL

  db.execute <<-SQL
    CREATE TABLE reading_lists (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      book_id INTEGER,
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(book_id) REFERENCES books(id)
    );
  SQL
end

def seed_books(db)
  books = [
    ["Harry Potter", "J.K. Rowling", "Wizard boy goes to magic school"],
    ["The Hobbit", "J.R.R. Tolkien", "A hobbit goes on an unexpected journey"],
    ["1984", "George Orwell", "A dystopian surveillance society"]
  ]

  books.each do |title, author, description|
    db.execute(
      "INSERT INTO books (title, author, description) VALUES (?, ?, ?)",
      [title, author, description]
    )
  end
end


seed!