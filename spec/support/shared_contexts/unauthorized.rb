# frozen_string_literal: true

RSpec.shared_context 'unauthorized' do
  context 'when JWT is invalid' do
    let(:access_token) { expired_jwt(user) }

    it 'returns unauthorized response' do
      expect(response).to be_unauthorized
      expect(response.parsed_body['errors'].first)
        .to eq('You are unauthorized to view this resource')
    end
  end
end
