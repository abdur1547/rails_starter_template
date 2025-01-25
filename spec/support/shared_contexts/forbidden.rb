# frozen_string_literal: true

RSpec.shared_context 'forbidden' do
  context 'when no JWT in headers' do
    let(:headers) { }

    it 'returns forbidden response' do
      expect(response).to be_forbidden
      expect(response.parsed_body['errors'].first)
        .to eq('JWT token is missing, JWT is required in headers of in params')
    end
  end
end
