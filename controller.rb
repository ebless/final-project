require 'sinatra'
require 'sinatra/activerecord'
require 'digest/md5'
require_relative "models/user.rb"
require_relative "models/post.rb"

enable :sessions

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://ebless:admin@localhost:5432/chirper')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)


get '/' do
	@posts = Post.all.order(created_at: :desc)
	erb :index
end

get '/create_user' do
	# Render page for creating user
	erb :create
end
post '/create_user' do
	# Create new user
	if params[:password] == params[:confirm_password] && User.find_by(username: params[:username]) == nil
		user = User.create(username: params[:username], password_digest: Digest::MD5.hexdigest(params[:password]))
		user.save
		session[:user] = user.id
		redirect '/'
	else
		"User did not validate"
	end
end

get '/login' do
	# Render page for logging in
	erb :login
end
post '/login' do
	# Validate user login
	user = User.find_by(username: params[:username])
	if user.password_digest == Digest::MD5.hexdigest(params[:password])
		session[:user] = user.id
		redirect '/'
	else
		"Login invalid"
	end
end

get '/logout' do
	#Logout the user
	session[:user] = nil
	redirect '/'
end

get '/create_post' do
	# Render page for creating posts
	erb :post
end

post '/create_post' do
	# Create new post
	if params[:title] && params[:content] && session[:user] && params[:content].length <= 180
		post = Post.create(title: params[:title], user_id: session[:user], content: params[:content])
		post.save
		redirect '/'
	end
end
get '/delete_post/:post' do
	# Delete posts
	if session[:user] == User.find_by(username: "admin").id || session[:user] == User.find_by(username: "COadmin").id
		post = Post.find_by(id: params[:post])
		post.destroy
		redirect '/'
	end
end
