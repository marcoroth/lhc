require 'rails_helper'

describe LHC::Endpoint do

  context 'compile' do

    it 'uses parameters for interpolation' do
      endpoint = LHC::Endpoint.new(':datastore/v2/:campaign_id/feedbacks')
      expect(
        endpoint.compile(datastore: 'http://datastore', campaign_id: 'abc')
      ).to eq "http://datastore/v2/abc/feedbacks"
    end

    it 'uses provided proc to find values' do
      endpoint = LHC::Endpoint.new(':datastore/v2')
      config = { datastore: 'http://datastore' }
      find_value = ->(match){
        config[match.gsub(':', '').to_sym]
      }
      expect(
        endpoint.compile(find_value)
      ).to eq "http://datastore/v2"
    end
  end
end
