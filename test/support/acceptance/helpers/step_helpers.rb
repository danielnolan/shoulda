require_relative 'file_helpers'
require_relative 'gem_helpers'

module AcceptanceTests
  module StepHelpers
    include FileHelpers
    include GemHelpers

=begin
    def add_shoulda_to_project(options = {})
      AddShouldaToProject.call(options)
    end
=end


=begin
    def create_rails_application
      fs.clean
      rails_new
      remove_unnecessary_gems
      add_minitest_to_project
    end

    def run_migrations
      run_rake_tasks!(['db:drop', 'db:create', 'db:migrate'])
    end

    def rails_new
      command = "bundle exec rails new #{fs.project_directory} --skip-bundle --no-rc --skip-turbolinks --skip-listen"

      run_command!(command) do |runner|
        runner.directory = nil
      end

      command
    end

    def remove_unnecessary_gems
      updating_bundle do |bundle|
        bundle.remove_gem 'turn'
        bundle.remove_gem 'coffee-rails'
        bundle.remove_gem 'uglifier'
        bundle.remove_gem 'debugger'
        bundle.remove_gem 'byebug'
        bundle.remove_gem 'web-console'
        bundle.remove_gem 'sqlite3'
        bundle.add_gem 'sqlite3', '~> 1.3.6'
      end
    end

    def add_minitest_to_project
      add_gem 'minitest-reporters'

      append_to_file 'test/test_helper.rb', <<-FILE
        require 'minitest/autorun'
        require 'minitest/reporters'

        Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
      FILE
    end
=end
  end
end
