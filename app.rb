require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'

enable :sessions

helpers do
  def current_user
    if session[:user_id]
      db = SQLite3::Database.new("db/library.db")
      db.results_as_hash = true
      db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first
    end
  end
end

get('/books') do
  db = SQLite3::Database.new("db/library.db")
  db.results_as_hash = true

  @books = db.execute("SELECT * FROM books")

  if current_user
    @reading_list = db.execute(
      "SELECT books.* FROM books
       JOIN reading_lists ON books.id = reading_lists.book_id
       WHERE reading_lists.user_id = ?",
       session[:user_id]
    )

    
    @reading_book_ids = @reading_list.map { |book| book["id"] }
  end

  slim(:index)
end

post('/register') do
  username = params[:username]
  password = params[:password]

  db = SQLite3::Database.new("db/library.db")
  db.execute("INSERT INTO users (username, password) VALUES (?,?)",
  [username, password])

  redirect('/books')
end

post('/login') do
  username = params[:username]
  password = params[:password]

  db = SQLite3::Database.new("db/library.db")
  db.results_as_hash = true

  user = db.execute(
    "SELECT * FROM users WHERE username = ? AND password = ?",
    [username, password]
  ).first

  if user
    session[:user_id] = user["id"]
  else
    session[:error] = "Register first to log in"
  end

  redirect('/books')
end

get('/logout') do
  session.clear
  redirect('/books')
end

post('/books/:id/add') do
  book_id = params[:id].to_i
  db = SQLite3::Database.new("db/library.db")

  db.execute(
    "INSERT INTO reading_lists (user_id, book_id) VALUES (?,?)",
    [session[:user_id], book_id]
  )

  redirect('/books')
end

post('/books/:id/remove') do
  book_id = params[:id].to_i
  db = SQLite3::Database.new("db/library.db")

  db.execute(
    "DELETE FROM reading_lists WHERE user_id = ? AND book_id = ?",
    [session[:user_id], book_id]
  )

  redirect('/books')
end
