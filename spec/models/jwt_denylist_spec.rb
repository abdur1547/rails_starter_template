require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      jwt_denylist = build(:jwt_denylist)
      expect(jwt_denylist).to be_valid
    end
  end

  describe 'database columns' do
    it { is_expected.to have_db_column(:jti).of_type(:string) }
    it { is_expected.to have_db_column(:exp).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'database indexes' do
    it { is_expected.to have_db_index(:jti).unique(true) }
  end

  describe 'revocation strategy' do
    it 'includes Devise::JWT::RevocationStrategies::Denylist' do
      expect(JwtDenylist.ancestors).to include(Devise::JWT::RevocationStrategies::Denylist)
    end
  end
end
