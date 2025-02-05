require 'porkbun'
require 'webmock/rspec'
ENV.store 'PORKBUN_API_KEY', 'YOUR_API_KEY'
ENV.store 'PORKBUN_SECRET_API_KEY', 'YOUR_SECRET_API_KEY'
describe Porkbun do
  context 'ping' do
    it 'should ping' do
      body = { status: 'SUCCESS', yourIp: '171.226.155.160' }
      stub_request(:post, 'https://api.porkbun.com/api/json/v3/ping')
        .with(body: {
                "secretapikey": 'YOUR_SECRET_API_KEY',
                "apikey": 'YOUR_API_KEY'
              })
        .to_return(status: 200, body: body.to_json, headers: {
                     'Content-Type' => 'application/json'
                   })
      expect(Porkbun.ping).to eq(body)
    end
  end
  context Porkbun::Domain do
    it 'should list all' do
      body = { status: 'SUCCESS',
               domains: [
                 { domain: 'borseth.ink',
                   status: 'ACTIVE',
                   tld: 'app',
                   createDate: '2018-08-20 17:52:51',
                   expireDate: '2023-08-20 17:52:51',
                   securityLock: '1',
                   whoisPrivacy: '1',
                   autoRenew: 0,
                   notLocal: 0 }
               ] }

      stub_request(:post, 'https://api.porkbun.com/api/json/v3/domain/listAll')
        .with(body: {
                "secretapikey": 'YOUR_SECRET_API_KEY',
                "apikey": 'YOUR_API_KEY'
              })
        .to_return(status: 200, body: body.to_json, headers: {
                     'Content-Type' => 'application/json'
                   })
      expect(Porkbun::Domain.list_all).to eq(body)
    end
  end
  context Porkbun::DNS do
    it 'should create' do
      request_body =
        { 'secretapikey' => 'YOUR_SECRET_API_KEY',
          'apikey' => 'YOUR_API_KEY',
          'name' => 'www',
          'content' => '1.1.1.1',
          'type' => 'A',
          'ttl' => 600 }

      response_body = {
        'status' => 'SUCCESS',
        'id' => '106926659'
      }

      stub_request(:post, 'https://api.porkbun.com/api/json/v3/dns/create/onepiece.com')
        .with(
          body: request_body.to_json
        )
        .to_return(status: 200, body: response_body.to_json, headers: {
                     'Content-Type' => 'application/json'
                   })

      record = Porkbun::DNS.create(name: 'www', content: '1.1.1.1', domain: 'onepiece.com',
                                   type: 'A')
      expect(record.id).to eq('106926659')
    end
  end
end
