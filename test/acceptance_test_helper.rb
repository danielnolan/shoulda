require_relative 'support/tests/current_bundle'

Tests::CurrentBundle.instance.assert_appraisal!

#---

require 'test_helper'

# acceptance_test_support_files =
  # Pathname.new('../support/acceptance/**/*.rb').expand_path(__FILE__)

# Dir.glob(acceptance_test_support_files).sort.each { |file| require file }

require_relative 'support/rails_application_with_shoulda'
require_relative 'support/acceptance/matchers/have_output'
require_relative 'support/acceptance/matchers/indicate_that_tests_were_run'

class AcceptanceTest < Minitest::Test
  # include AcceptanceTests::Helpers
  include AcceptanceTests::Matchers

  private

  def app
    @app ||= RailsApplicationWithShoulda.new
  end
end
