# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "requires an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "requires a unique email" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "requires a name" do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end
  end

  describe "devise modules" do
    it "includes database_authenticatable" do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it "includes registerable" do
      expect(User.devise_modules).to include(:registerable)
    end

    it "includes recoverable" do
      expect(User.devise_modules).to include(:recoverable)
    end

    it "includes rememberable" do
      expect(User.devise_modules).to include(:rememberable)
    end

    it "includes validatable" do
      expect(User.devise_modules).to include(:validatable)
    end

    it "includes trackable" do
      expect(User.devise_modules).to include(:trackable)
    end

    it "includes omniauthable" do
      expect(User.devise_modules).to include(:omniauthable)
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new({
        provider: "google_oauth2",
        uid: "12345",
        info: {
          email: "oauth@example.com",
          name: "OAuth User",
          image: "https://example.com/avatar.jpg"
        }
      })
    end

    it "creates a new user from omniauth data" do
      expect {
        User.from_omniauth(auth)
      }.to change(User, :count).by(1)
    end

    it "sets the correct attributes" do
      user = User.from_omniauth(auth)
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("12345")
      expect(user.email).to eq("oauth@example.com")
      expect(user.name).to eq("OAuth User")
      expect(user.avatar_url).to eq("https://example.com/avatar.jpg")
    end

    it "finds existing user with same provider and uid" do
      existing_user = User.from_omniauth(auth)
      expect {
        User.from_omniauth(auth)
      }.not_to change(User, :count)

      expect(User.from_omniauth(auth)).to eq(existing_user)
    end
  end

  describe "#display_name" do
    it "returns the name when present" do
      user = build(:user, name: "John Doe", email: "john@example.com")
      expect(user.display_name).to eq("John Doe")
    end

    it "returns the email when name is blank" do
      user = build(:user, name: "", email: "john@example.com")
      expect(user.display_name).to eq("john@example.com")
    end
  end

  describe "factory" do
    it "has a valid factory" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "creates a valid user with google oauth trait" do
      user = build(:user, :with_google_oauth)
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to be_present
      expect(user.avatar_url).to be_present
    end

    it "creates a valid user with tracking trait" do
      user = build(:user, :with_tracking)
      expect(user.sign_in_count).to eq(5)
      expect(user.current_sign_in_at).to be_present
      expect(user.last_sign_in_at).to be_present
    end
  end
end
