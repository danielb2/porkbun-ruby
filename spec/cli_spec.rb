require 'porkbun'
require 'thor'
load File.expand_path('../bin/porkbun', __dir__)

describe CLI do
  describe '.list' do
    it 'lists all domains' do
      allow(Porkbun::Domain).to receive(:list_all).and_return(
        domains: [{ domain: 'onepiece.com' }]
      )

      expect { CLI.start(['list']) }.to output("onepiece.com\n").to_stdout
    end

    it 'lists records for a specific domain' do
      record = instance_double(Porkbun::DNS, to_s: 'www.onepiece.com A 1.1.1.1')
      allow(Porkbun::DNS).to receive(:list).with('onepiece.com', '').and_return([record])

      expect { CLI.start(['list', 'onepiece.com']) }
        .to output("www.onepiece.com A 1.1.1.1\n").to_stdout
    end
  end

  it 'supports ls as an alias for list' do
    allow(Porkbun::Domain).to receive(:list_all).and_return(domains: [])

    expect { CLI.start(['ls']) }.not_to raise_error
    expect(Porkbun::Domain).to have_received(:list_all)
  end


  it 'shows help for list' do
    expect { CLI.start(['help', 'list']) }
      .to output(/Usage:\n  porkbun list/).to_stdout
  end

  it 'shows ls in the command help' do
    expect { CLI.start(['help']) }
      .to output(/porkbun ls/).to_stdout
  end
end
