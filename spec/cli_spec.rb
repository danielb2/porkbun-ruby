require 'porkbun'
require 'tempfile'
require 'thor'
load File.expand_path('../bin/porkbun', __dir__)

describe CLI do
  describe '.ls' do
    it 'lists all domains' do
      allow(Porkbun::Domain).to receive(:list_all).and_return(
        domains: [{ domain: 'onepiece.com' }]
      )

      expect { CLI.start(['ls']) }.to output("onepiece.com\n").to_stdout
    end

    it 'lists records for a specific domain' do
      record = instance_double(Porkbun::Record, to_s: 'www.onepiece.com A 1.1.1.1')
      domain = instance_double(Porkbun::Domain, records: [record])
      allow(Porkbun).to receive(:new).with('onepiece.com').and_return(domain)

      expect { CLI.start(['ls', 'onepiece.com']) }
        .to output("www.onepiece.com A 1.1.1.1\n").to_stdout
    end
  end



  it 'shows help for ls' do
    expect { CLI.start(['help', 'ls']) }
      .to output(/Usage:\n  porkbun ls/).to_stdout
  end

  it 'shows ls in the command help' do
    expect { CLI.start(['help']) }.to output(/porkbun ls/).to_stdout
  end

  it 'creates a record' do
    record = double(to_s: 'www.onepiece.com A 1.1.1.1', message: 'created')
    allow(Porkbun::Domain).to receive(:create_record).and_return(record)

    expect {
      CLI.start(['add', 'www.onepiece.com', '--type', 'A', '--content', '1.1.1.1'])
    }.to output("www.onepiece.com A 1.1.1.1\ncreated\n").to_stdout
    expect(Porkbun::Domain).to have_received(:create_record).with(
      'www.onepiece.com', hash_including(type: 'A', content: '1.1.1.1')
    )
  end

  it 'updates record content and TTL' do
    record = double(name: 'foo', domain: 'domain.org', content: '1.1.1.1', ttl: 600, to_s: 'foo.domain.org A 2.2.2.2', message: 'updated')
    allow(record).to receive(:content=)
    allow(record).to receive(:name=)
    allow(record).to receive(:ttl=)
    allow(record).to receive(:save)
    allow(Porkbun::Domain).to receive(:get_record).and_return(record)
    allow(record).to receive(:update).and_return(record)

    expect { CLI.start(['up', 'foo.domain.org', '--content', '2.2.2.2', '--ttl', '700']) }
      .to output("UPDATE foo.domain.org A 2.2.2.2\nupdated\n").to_stdout
    expect(Porkbun::Domain).to have_received(:get_record).with('foo.domain.org')
    expect(record).to have_received(:update).with(hash_including('content' => '2.2.2.2', 'ttl' => 700))
  end

  it 'prints environment variables' do
    expect { CLI.start(['env']) }
      .to output("PORKBUN_API_KEY: YOUR_API_KEY\nPORKBUN_SECRET_API_KEY: YOUR_SECRET_API_KEY\n").to_stdout
  end

  it 'deletes non-NS records' do
    a_record = double(type: 'A', to_s: 'www.onepiece.com A 1.1.1.1')
    domain = instance_double(Porkbun::Domain, delete_all_records: [a_record])
    allow(Porkbun).to receive(:new).and_return(domain)

    expect { CLI.start(['rm_rf', 'onepiece.com']) }
      .to output("DELETE www.onepiece.com A 1.1.1.1\n").to_stdout
    expect(domain).to have_received(:delete_all_records)
  end

  it 'deletes all records for a hostname with or without a trailing dot' do
    record = double(name: 'foo', to_s: 'foo.domain.org A 1.1.1.1')
    allow(record).to receive(:delete)
    allow(Porkbun::Domain).to receive(:get_record).and_return(record)

    %w[foo.domain.org foo.domain.org.].each do |hostname|
      expect { CLI.start(['rm', hostname]) }
        .to output("DELETE foo.domain.org A 1.1.1.1\n").to_stdout
    end
    expect(Porkbun::Domain).to have_received(:get_record).twice
  end

  it 'updates an existing dynamic DNS record' do
    record = double(name: 'home.onepiece.com', content: '1.1.1.1', to_s: 'home.onepiece.com A 2.2.2.2', message: 'updated')
    allow(Porkbun::Domain).to receive(:update_dynamic).and_return(
      created: false, display: 'home.onepiece.com A 2.2.2.2', record: record
    )

    expect { CLI.start(['dyndns', 'home.onepiece.com', '2.2.2.2']) }
      .to output("UPDATE home.onepiece.com A 2.2.2.2\nupdated\n").to_stdout
    expect(Porkbun::Domain).to have_received(:update_dynamic).with('home.onepiece.com', '2.2.2.2')
  end

  it 'imports records from a zone file' do
    file = Tempfile.new(['zone', '.txt'])
    file.write("www.onepiece.com. 600 IN A 1.1.1.1\n")
    file.close
    record = Object.new
    def record.inspect
      'www.onepiece.com A 1.1.1.1'
    end
    allow(Porkbun::Domain).to receive(:import).and_return([record])

    expect { CLI.start(['import', file.path]) }.to output("www.onepiece.com A 1.1.1.1\n").to_stdout
    expect(Porkbun::Domain).to have_received(:import).with(file.path)
  ensure
    file&.unlink
  end
end
