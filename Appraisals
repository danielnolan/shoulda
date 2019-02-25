shared_dependencies = proc do
  gem 'bcrypt'
  gem 'jquery-rails'
  gem 'sass-rails'
  gem 'sqlite3', '~> 1.3.6'
  gem 'rspec', '~> 3.0'
  gem 'shoulda-context', git: '~/code/tbot/shoulda-context'
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers'
  gem 'rails-controller-testing'
end

appraise '4.2' do
  instance_eval(&shared_dependencies)
  gem 'rails', git: 'https://github.com/rails/rails.git', branch: '4-2-stable'
end

appraise '5.0' do
  instance_eval(&shared_dependencies)
  gem 'rails', '5.0.1'
end
