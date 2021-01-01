# frozen_string_literal: true

puts 'Please enter the project name'
PROJECT_NAME = gets.chomp

def start
  system "npx create-react-app #{PROJECT_NAME}-client"
  add_package_json
end

def add_package_json
  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-client") do
    File.open('package.json', 'r+') do |f|
      f << <<~HEREDOC
        {
"name": "#{PROJECT_NAME}",
"version": "0.1.0",
"private": true,
"dependencies": {
  "@material-ui/core": "^4.2.1",
  "@material-ui/icons": "^4.2.1",
  "@material-ui/lab": "^4.0.0-alpha.25",
  "axios": "^0.19.0",
  "axios-hooks": "^1.3.0",
  "clsx": "^1.1.0",
  "eslint-config-airbnb": "^18.0.1",
  "eslint-config-airbnb-base": "^14.0.0",
  "eslint-plugin-import": "^2.20.1",
  "history": "^4.10.1",
  "notistack": "^0.9.5",
  "prop-types": "^15.7.2",
  "react": "^17.0.1",
  "react-dom": "^17.0.1",
  "react-router-dom": "^5.1.2",
  "react-scripts": "^3.4.0",
  "redux": "^4.0.5",
  "redux-thunk": "^2.3.0",
  "jwt-decode": "^2.2.0",
  "zxcvbn": "^4.4.2"
},
"scripts": {
  "start": "PORT=7001 react-scripts start",
  "build": "react-scripts build",
  "test": "react-scripts test",
  "eject": "react-scripts eject"
},
"eslintConfig": {
  "extends": "react-app"
},
"browserslist": {
  "production": [
    ">0.2%",
    "not dead",
    "not op_mini all"
  ],
  "development": [
    "last 1 chrome version",
    "last 1 firefox version",
    "last 1 safari version"
  ]
}
}

      HEREDOC
    end
  end
  install_packages
end

def install_packages
  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-client") { system 'npm i --legacy-peer-deps' }
  add_react_customisations
end

def add_react_customisations
  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-client/src") do
    system 'mkdir constants containers config components'
    system 'touch Store.js'
    system 'touch .env'
    system 'rm logo.svg'
  end
  add_rails_question
end

def add_rails_question
  is_invaild = true

  options = ['1: No', '2: Yes']

  while is_invaild
    puts 'Add Rails API (Postgres)?'

    options.each { |x| puts x }

    answer = gets.chomp.to_i

    next unless answer != 0 && answer < 3

    is_invaild = false

    if answer == 2
      create_rails_api
    else
      puts 'Happy Hacking!'
    end
  end
end

def create_rails_api
  system ("rails new #{PROJECT_NAME}-api --api --database=postgresql")
  add_api_customisations
end

def change_dir(path); end

def add_api_customisations
  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-api/lib/tasks") do
    system 'touch db_rebuild_all.rb'
    File.open('db_rebuild_all.rb', 'r+') do |f|
      f << <<~HEREDOC
# bundle exec rake db_tasks:rebuild
namespace :db_tasks do
  desc "Rebuild database"
  task :rebuild, [] => :environment do
    raise "Not allowed to run on production" if Rails.env.production?

    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end
end
      HEREDOC
    end
  end

  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-api/config/initializers") do
    File.open('cors.rb', 'r+') do |f|
      f << <<~HEREDOC
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
      HEREDOC
    end
  end

  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-api") do
    repo = nil
    File.open('Gemfile', 'r+') do |f|
      f << <<~HEREDOC
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'devise'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'rb-readline'
gem 'active_model_serializers', '~> 0.10.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
  gem 'factory_bot_rails', '~> 6.1'
  gem 'shoulda-matchers', '~> 4.3'
  gem 'faker'
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rubocop'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

      HEREDOC
    end
  end

  bundle_rails_gems
end

def bundle_rails_gems
  Dir.chdir("#{Dir.pwd}/#{PROJECT_NAME}-api") do
    system 'bundle update'
    system 'bundle'
  end
end

start
# add_rails_question
