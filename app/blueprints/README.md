# Blueprints

This directory contains API serializers using [Blueprinter](https://github.com/procore/blueprinter).

## Structure

```
app/blueprints/
├── base_blueprint.rb      # Base class with common functionality
├── user_blueprint.rb      # User serialization
├── order_blueprint.rb     # Order serialization
└── error_blueprint.rb     # Error response formatting
```

## Quick Reference

### Basic Usage

```ruby
# Single object
UserBlueprint.render(user)

# Collection
UserBlueprint.render(users)

# With root key
UserBlueprint.render(users, root: :users)

# Specific view
UserBlueprint.render(user, view: :detailed)

# As hash (for composition)
UserBlueprint.render_as_hash(user)
```

### In Controllers

```ruby
class Api::V1::UsersController < ApplicationController
  def show
    user = User.find(params[:id])
    render json: UserBlueprint.render(user)
  end
  
  def index
    users = User.all
    render json: UserBlueprint.render(users, root: :users)
  end
end
```

## Creating New Blueprints

```ruby
# app/blueprints/post_blueprint.rb
class PostBlueprint < BaseBlueprint
  identifier :id
  
  # Simple fields
  fields :title, :body, :published
  
  # Timestamps helper
  timestamps
  
  # Association
  association :author, blueprint: UserBlueprint
  
  # Custom field
  field :excerpt do |post|
    post.body&.truncate(100)
  end
  
  # View
  view :detailed do
    fields :created_at, :updated_at
    association :comments, blueprint: CommentBlueprint
  end
end
```

## Available Views

### UserBlueprint
- **default**: id, email, name
- **detailed**: + timestamps, sign-in info
- **profile**: name, email, avatar, member_since
- **with_token**: for authentication responses
- **minimal**: id, name only

### OrderBlueprint
- **default**: id, status, total, created_at
- **detailed**: + user_id, items, payment info
- **minimal**: id, status, total

## Testing

```ruby
RSpec.describe UserBlueprint do
  it 'renders user data' do
    user = create(:user)
    result = described_class.render_as_hash(user)
    
    expect(result[:id]).to eq(user.id)
    expect(result[:email]).to eq(user.email)
  end
end
```

## Full Documentation

See [doc/BLUEPRINTER_USAGE.md](../../doc/BLUEPRINTER_USAGE.md) for comprehensive guide.
