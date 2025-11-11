# Mission Control Jobs Setup

This document explains how Mission Control Jobs has been configured in this Rails application.

## What is Mission Control Jobs?

Mission Control Jobs is a Rails-based dashboard for managing and monitoring Active Job background jobs. It provides a user-friendly interface to:
- Inspect job queues and their status
- View pending, scheduled, in-progress, and failed jobs
- Retry or discard failed jobs
- Monitor workers and their activity
- Filter jobs by queue name and job class
- Pause and un-pause queues (if the adapter supports it)

## Installation

The gem has been added to the `Gemfile`:

```ruby
gem "mission_control-jobs"
```

## Configuration

### Routes

Mission Control Jobs is mounted at `/jobs` in `config/routes.rb`:

```ruby
mount MissionControl::Jobs::Engine, at: "/jobs"
```

### Authentication

The configuration is set in `config/initializers/mission_control_jobs.rb`:

- **Development Environment**: Authentication is **disabled** by default for easier access
- **Production Environment**: You should configure authentication using Rails credentials

#### Setting up Production Authentication

Run the provided generator to configure credentials:

```bash
bin/rails mission_control:jobs:authentication:configure
```

This will add credentials to your encrypted credentials file:

```yaml
mission_control:
  http_basic_auth_user: your_username
  http_basic_auth_password: your_password
```

Alternatively, you can manually set credentials in the initializer using environment variables.

### Adapter Configuration

Mission Control Jobs automatically detects your Active Job adapter. This project uses **Solid Queue**, which is configured in:
- `config/queue.yml` - Queue configuration
- `config/application.rb` - Active Job adapter setting

## Usage

### Accessing the Dashboard

Once your Rails server is running, access Mission Control Jobs at:

```
http://localhost:3000/jobs
```

In development, you can access it directly without authentication (unless you've enabled it).

### Console Helpers

Mission Control Jobs provides console helpers for scripting and managing large sets of jobs:

```ruby
# Connect to a job server
connect_to "app_name:solid_queue"

# Query jobs
ActiveJob.jobs                                              # All jobs
ActiveJob.jobs.failed                                       # Failed jobs
ActiveJob.jobs.pending.where(queue_name: "default")        # Pending jobs in a queue
ActiveJob.jobs.failed.where(job_class_name: "SomeJob")     # Failed jobs of a class

# Bulk operations
ActiveJob.jobs.failed.retry_all                            # Retry all failed jobs
ActiveJob.jobs.failed.where(job_class_name: "SomeJob").retry_all
ActiveJob.jobs.failed.discard_all                          # Discard all failed jobs
ActiveJob.jobs.pending.where(queue_name: "some-queue").discard_all
```

### Available Features with Solid Queue

With Solid Queue as the adapter, Mission Control Jobs supports:
- Viewing jobs in different states (pending, scheduled, in-progress, failed, finished)
- Filtering by queue name and job class
- Retrying and discarding failed jobs
- Viewing worker information
- Monitoring recurring tasks

## Configuration Options

All configuration options are available in `config/initializers/mission_control_jobs.rb`:

```ruby
# Disable authentication (development only)
config.mission_control.jobs.http_basic_auth_enabled = false

# Set custom base controller for authentication
config.mission_control.jobs.base_controller_class = "AdminController"

# Configure pagination
config.mission_control.jobs.jobs_per_page = 25
config.mission_control.jobs.workers_per_page = 25

# Filter sensitive job arguments
config.mission_control.jobs.filter_arguments = [ "password", "token" ]

# Configure bulk operation delays
config.mission_control.jobs.delay_between_bulk_operation_batches = 0

# Configure query limits
config.mission_control.jobs.internal_query_count_limit = 500_000
```

## Security Considerations

1. **Production Authentication**: Always enable authentication in production environments
2. **Sensitive Data**: Use `filter_arguments` to hide sensitive data from the UI
3. **Access Control**: Consider using a custom base controller for role-based access
4. **Network Security**: In production, consider restricting access to the `/jobs` path via firewall or load balancer rules

## Testing Jobs

To test Mission Control Jobs, you can create a sample job:

```ruby
# app/jobs/test_job.rb
class TestJob < ApplicationJob
  queue_as :default

  def perform(message)
    puts "Processing: #{message}"
    # Simulate some work
    sleep 2
  end
end
```

Then enqueue it in the console:

```ruby
TestJob.perform_later("Hello from Mission Control!")
```

Visit `http://localhost:3000/jobs` to see the job in the dashboard.

## Troubleshooting

### Jobs not appearing in dashboard
- Ensure Solid Queue is running: `bin/jobs` (starts the job processor)
- Check that jobs are being enqueued: `ActiveJob.jobs.count` in console

### Authentication issues
- In development: Verify `http_basic_auth_enabled = false` in the initializer
- In production: Check your credentials are properly set

### Performance with many jobs
- Adjust `internal_query_count_limit` if you have more than 500k jobs
- Use filters to narrow down job lists

## Additional Resources

- [Mission Control Jobs GitHub](https://github.com/rails/mission_control-jobs)
- [Solid Queue Documentation](https://github.com/rails/solid_queue)
- [Active Job Guide](https://guides.rubyonrails.org/active_job_basics.html)
