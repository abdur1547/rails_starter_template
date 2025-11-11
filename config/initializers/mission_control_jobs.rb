# frozen_string_literal: true

# Configuration for Mission Control Jobs
# https://github.com/rails/mission_control-jobs

Rails.application.configure do
  # Configure basic HTTP authentication for the Mission Control dashboard
  # For development, you can disable authentication or use simple credentials
  # For production, use environment variables and ensure strong credentials

  if Rails.env.development?
    # Option 1: Disable authentication in development (uncomment below)
    config.mission_control.jobs.http_basic_auth_enabled = false

    # Option 2: Enable basic auth in development (comment line above and uncomment below)
    # config.mission_control.jobs.http_basic_auth_user = "admin"
    # config.mission_control.jobs.http_basic_auth_password = "password"
  else
    # Production: Use credentials from Rails credentials
    # Run: bin/rails mission_control:jobs:authentication:configure
    # Or set via environment variables:
    # config.mission_control.jobs.http_basic_auth_user = ENV.fetch("MISSION_CONTROL_USER", "admin")
    # config.mission_control.jobs.http_basic_auth_password = ENV.fetch("MISSION_CONTROL_PASSWORD", "changeme")
  end

  # Configure which adapters to include
  # By default, all adapters configured in your application are included
  # config.mission_control.jobs.adapters = [ :solid_queue ]

  # Configure the base controller class for custom authentication
  # config.mission_control.jobs.base_controller_class = "AdminController"

  # Configure the number of items to display per page
  # config.mission_control.jobs.jobs_per_page = 25
  # config.mission_control.jobs.workers_per_page = 25
  # config.mission_control.jobs.recurring_tasks_per_page = 25

  # Configure delay between bulk operation batches
  # config.mission_control.jobs.delay_between_bulk_operation_batches = 0

  # Configure internal query count limit
  # config.mission_control.jobs.internal_query_count_limit = 500_000

  # Configure scheduled job delay threshold
  # config.mission_control.jobs.scheduled_job_delay_threshold = 1.minute

  # Show console help
  # config.mission_control.jobs.show_console_help = true

  # Configure backtrace cleaner
  # config.mission_control.jobs.backtrace_cleaner = Rails::BacktraceCleaner.new

  # Filter sensitive job arguments
  # config.mission_control.jobs.filter_arguments = [ "password", "token" ]
end
