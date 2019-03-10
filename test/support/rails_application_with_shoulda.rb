require_relative 'add_shoulda_to_project'
require_relative 'snowglobe'

class RailsApplicationWithShoulda < Snowglobe::RailsApplication
  def create
    super

    bundle.updating do
      bundle.add_gem 'minitest-reporters'
      AddShouldaToProject.call(
        self,
        test_framework: :minitest,
        libraries: [:rails],
      )
    end

    fs.append_to_file 'test/test_helper.rb', <<-FILE
      require 'minitest/autorun'
      require 'minitest/reporters'

      Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
    FILE
  end
end
