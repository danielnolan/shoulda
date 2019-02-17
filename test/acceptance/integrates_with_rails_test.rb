require 'acceptance_test_helper'

class ShouldaIntegratesWithRailsTest < AcceptanceTest
  def test_succeeding_assertions
    create_rails_application_with_shoulda

    write_file 'db/migrate/1_create_users.rb', <<-FILE
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :categories_users do |t|
            t.integer :category_id
            t.integer :user_id
          end

          create_table :categories do |t|
          end

          create_table :cities do |t|
          end

          create_table :lives do |t|
            t.integer :user_id
          end

          create_table :issues do |t|
            t.integer :user_id
          end

          create_table :users do |t|
            t.integer :account_id
            t.integer :city_id
            t.string :email
            t.integer :age
            t.integer :status
            t.string :aspects
          end

          add_index :users, :account_id
        end
      end
    FILE

    run_migrations

    write_file 'app/models/category.rb', <<-FILE
      class Category < ActiveRecord::Base
      end
    FILE

    write_file 'app/models/city.rb', <<-FILE
      class City < ActiveRecord::Base
      end
    FILE

    write_file 'app/models/issue.rb', <<-FILE
      class Issue < ActiveRecord::Base
      end
    FILE

    write_file 'app/models/life.rb', <<-FILE
      class Life < ActiveRecord::Base
      end
    FILE

    write_file 'app/models/person.rb', <<-FILE
      class Person
        include ActiveModel::Model
        include ActiveModel::SecurePassword

        attr_accessor(
          :age,
          :card_number,
          :email,
          :foods,
          :nothing,
          :password_digest,
          :some_other_attribute,
          :some_other_attribute_confirmation,
          :something,
          :terms_of_service,
          :workouts,
          :some_other_attribute,
        )

        has_secure_password

        validates_absence_of :nothing
        validates_acceptance_of :terms_of_service
        validates_confirmation_of :password
        validates_exclusion_of :workouts, in: ["biceps"]
        validates_inclusion_of :foods, in: ["spaghetti"]
        validates_length_of :card_number, maximum: 16
        validates_numericality_of :age
        validates_presence_of :something

        validate :email_looks_like_an_email

        delegate :a_method, to: :some_delegate_object

        def some_delegate_object
          Object.new.instance_eval do
            def a_method; end
          end
        end

        private

        def email_looks_like_an_email
          if email !~ /@/
            errors.add :email, "invalid"
          end
        end
      end
    FILE

    write_file 'app/models/user.rb', <<-FILE
      class User < ActiveRecord::Base
        belongs_to :city
        enum status: { inactive: 0, active: 1 }
        attr_readonly :username
        has_and_belongs_to_many :categories
        has_many :issues
        has_one :life
        serialize :aspects
        validates_uniqueness_of :email
        accepts_nested_attributes_for :issues
      end
    FILE

    write_file 'app/controllers/examples_controller.rb', <<-FILE
      class ExamplesController < ApplicationController
        before_action :some_before_action
        after_action :some_after_action
        around_action :some_around_action

        rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

        layout "application"

        def index
          render :index
          head :ok
        end

        def create
          create_params
          flash[:success] = "Example created"
          session[:some_key] = "some value"
          redirect_to action: :index
        end

        def handle_not_found
        end

        private

        def some_before_action
        end

        def some_after_action
        end

        def some_around_action
          yield
        end

        def create_params
          params.require(:user).permit(:email, :password)
        end
      end
    FILE

    write_file 'app/views/examples/index.html.erb', <<-FILE
      Some content here
    FILE

    write_file 'config/routes.rb', <<-FILE
      Rails.application.routes.draw do
        resources :examples, only: [:index, :create]
      end
    FILE

    write_file 'test/models/person_test.rb', <<-FILE
      require 'test_helper'

      class PersonTest < ActiveSupport::TestCase
        # See issue #999 in shoulda-matchers
        extend Shoulda::Matchers::Independent

        should allow_value("john@smith.com").for(:email)
        should_not allow_value("john").for(:email)

        should have_secure_password

        should validate_absence_of(:nothing)
        should_not validate_absence_of(:some_other_attribute)

        should validate_acceptance_of(:terms_of_service)
        should_not validate_acceptance_of(:some_other_attribute)

        should validate_confirmation_of(:password)
        should_not validate_confirmation_of(:some_other_attribute)

        should validate_exclusion_of(:workouts).in_array(["biceps"])
        should_not validate_exclusion_of(:some_other_attribute).
          in_array(["whatever"])

        should validate_inclusion_of(:foods).in_array(["spaghetti"])
        should_not validate_inclusion_of(:some_other_attribute).
          in_array(["whatever"])

        should validate_length_of(:card_number).is_at_most(16)
        should_not validate_length_of(:some_other_attribute).is_at_most(16)

        should validate_numericality_of(:age)
        should_not validate_numericality_of(:some_other_attribute)

        should validate_presence_of(:something)
        should_not validate_presence_of(:some_other_attribute)

        should delegate_method(:a_method).to(:some_delegate_object)
        should_not delegate_method(:some_other_method).to(:some_other_object)
      end
    FILE

    write_file 'test/models/user_test.rb', <<-FILE
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        should belong_to(:city)
        should_not belong_to(:some_other_attribute)

        should define_enum_for(:status).with(inactive: 0, active: 1)
        should_not define_enum_for(:status).with(foo: "bar")

        should have_db_column(:age)
        should_not have_db_column(:some_other_attribute)

        should have_db_index(:account_id)
        should_not have_db_index(:some_other_attribute)

        should have_readonly_attribute(:username)
        should_not have_readonly_attribute(:some_other_attribute)

        should have_and_belong_to_many(:categories)
        should_not have_and_belong_to_many(:whatevers)

        should have_many(:issues)
        should_not have_many(:whatevers)

        should have_one(:life)
        should_not have_one(:whatever)

        should serialize(:aspects)
        should_not serialize(:age)

        should validate_uniqueness_of(:email)
        should_not validate_uniqueness_of(:some_other_attribute)

        should accept_nested_attributes_for(:issues)
        should_not accept_nested_attributes_for(:some_other_attribute)
      end
    FILE

    write_file 'test/controllers/examples_controller_test.rb', <<-FILE
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        context "GET #index" do
          setup do
            get :index
          end

          should use_before_action(:some_before_action)
          should_not use_before_action(:some_other_before_action)
          should use_after_action(:some_after_action)
          should_not use_after_action(:some_other_after_action)
          should use_around_action(:some_around_action)
          should_not use_around_action(:some_other_around_action)

          should filter_param(:password)
          should_not filter_param(:some_other_param)

          should rescue_from(ActiveRecord::RecordNotFound).
            with(:handle_not_found)

          should render_template(:index)
          should_not render_template(:some_other_action)

          should render_with_layout("application")
          should_not render_with_layout("some_other_layout")

          should respond_with(:ok)
          should_not respond_with(:some_other_status)

          should route(:get, "/examples").to(action: :index)
          should_not route(:get, "/examples").to(action: :something_else)
        end

        context "POST #create" do
          should "permit correct params" do
            user_params = {
              user: {
                email: "some@email.com",
                password: "somepassword"
              }
            }
            positive_matcher = permit(:email, :password).
              for(:create, params: user_params).
              on(:user)
            negative_matcher = permit(:foo, :bar).
              for(:create, params: user_params).
              on(:user)
            assert_accepts positive_matcher, subject
            assert_rejects negative_matcher, subject
          end

          context "inner context" do
            setup do
              user_params = {
                user: {
                  email: "some@email.com",
                  password: "somepassword"
                }
              }
              post :create, user_params
            end

            should redirect_to("/examples")
            should_not redirect_to("/something_else")

            should set_flash[:success].to("Example created")
            should_not set_flash[:success].to("Something else")

            should set_session[:some_key].to("some value")
            should_not set_session[:some_key].to("some other value")
          end
        end
      end
    FILE

    result = run_n_unit_test_suite

    assert_accepts indicate_that_tests_were_run(failures: 0), result
  end

  def test_failing_positive_assertions
    create_rails_application_with_shoulda

    write_file 'db/migrate/1_create_users.rb', <<-FILE
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.string :name
          end
        end
      end
    FILE

    run_migrations

    write_file 'app/models/person.rb', <<-FILE
      class Person
        include ActiveModel::Model

        attr_accessor(
          :age,
          :card_number,
          :email,
          :foods,
          :nothing,
          :password,
          :password_confirmation,
          :password_digest,
          :some_other_attribute,
          :some_other_attribute_confirmation,
          :something,
          :terms_of_service,
          :workouts,
          :some_other_attribute,
        )

        validates_format_of :email, with: /\Aspecific value\Z/
      end
    FILE

    write_file 'app/models/user.rb', <<-FILE
      class User < ActiveRecord::Base
      end
    FILE

    write_file 'app/controllers/examples_controller.rb', <<-FILE
      class ExamplesController < ApplicationController
        def index
          head :not_found
        end

        def create
          head :not_found
        end
      end
    FILE

    write_file 'config/routes.rb', <<-FILE
      Rails.application.routes.draw do
        resources :examples, only: [:index, :create]
      end
    FILE

    write_file 'test/models/person_test.rb', <<-FILE
      require 'test_helper'

      class PersonTest < ActiveSupport::TestCase
        setup do
          @subject = Person.new
        end

        # See issue #999 in shoulda-matchers
        extend Shoulda::Matchers::Independent

        should allow_value("non-matching value").for(:email)
        should have_secure_password
        should validate_absence_of(:nothing)
        # should fail, doesn't
        should validate_acceptance_of(:terms_of_service)
        should validate_confirmation_of(:password)
        # should fail, doesn't
        should validate_exclusion_of(:workouts).in_array(["biceps"])
        # is erroring for some reason
        should validate_inclusion_of(:foods).in_array(["spaghetti"])
        # should fail, doesn't
        should validate_length_of(:card_number).is_at_most(16)
        # should fail, doesn't
        should validate_numericality_of(:age)
        # should fail, doesn't
        should validate_presence_of(:something)
        should delegate_method(:a_method).to(:some_delegate_object)
      end
    FILE

    write_file 'test/models/user_test.rb', <<-FILE
      require 'test_helper'

      class UserTest < ActiveSupport::TestCase
        should belong_to(:city)
        should define_enum_for(:status).with(inactive: 0, active: 1)
        should have_db_column(:age)
        should have_db_index(:account_id)
        should have_readonly_attribute(:username)
        should have_and_belong_to_many(:categories)
        should have_many(:issues)
        should have_one(:life)
        should serialize(:aspects)
        should validate_uniqueness_of(:email)
        should accept_nested_attributes_for(:issues)
      end
    FILE

    write_file 'test/controllers/examples_controller_test.rb', <<-FILE
      require 'test_helper'

      class ExamplesControllerTest < ActionController::TestCase
        context "GET #index" do
          setup do
            get :index
          end

          should use_before_action(:some_before_action)
          should use_after_action(:some_after_action)
          should use_around_action(:some_around_action)
          should filter_param(:some_param)
          should rescue_from(ActiveRecord::RecordNotFound).
            with(:handle_not_found)
          should render_template(:index)
          should render_with_layout("application")
          should respond_with(:ok)
          should route(:get, "/whatevers").to(action: :index)
        end

        context "POST #create" do
          should "permit correct params" do
            user_params = {
              user: {
                email: "some@email.com",
                password: "somepassword"
              }
            }
            positive_matcher = permit(:email, :password).
              for(:create, params: user_params).
              on(:user)
            negative_matcher = permit(:foo, :bar).
              for(:create, params: user_params).
              on(:user)
            assert_accepts positive_matcher, subject
            assert_rejects negative_matcher, subject
          end

          context "inner context" do
            setup do
              user_params = {
                user: {
                  email: "some@email.com",
                  password: "somepassword"
                }
              }
              post :create, user_params
            end

            should redirect_to("/examples")
            should set_flash[:success].to("Example created")
            should set_session[:some_key].to("some value")
          end
        end
      end
    FILE

    result = run_n_unit_test_suite

    assert_accepts indicate_that_tests_were_run(failures: 37), result
  end

  private

  def create_rails_application_with_shoulda
    create_rails_application

    updating_bundle do
      add_shoulda_to_project(
        test_frameworks: [:minitest],
        libraries: [:rails],
      )
    end
  end
end
