require 'porkbun'
require 'webmock/rspec'
describe Porkbun do
  it 'should ping' do
    body = { 'status' => 'SUCCESS', 'yourIp' => '171.226.155.160' }
    stub_request(:post, 'https://porkbun.com/api/json/v3/ping')
      .to_return(status: 200, body: body.to_json, headers: {
                   'Content-Type' => 'application/json'
                 })
    expect(Porkbun.ping).to eq({ 'status' => 'SUCCESS', 'yourIp' => '171.226.155.160' })
  end
end
