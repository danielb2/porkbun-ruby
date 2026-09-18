# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require_relative 'porkbun/version'

module Porkbun
  class Error < StandardError; end

  def self.porkbun(path, options = {})
    if ENV.fetch('PORKBUN_API_KEY', nil).nil? || ENV.fetch('PORKBUN_SECRET_API_KEY', nil).nil?
      abort 'PORKBUN_API_KEY and PORKBUN_SECRET_API_KEY must be set'
    end
    uri = URI(File.join('https://api.porkbun.com/api/json/v3', path))
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      secretapikey: ENV.fetch('PORKBUN_SECRET_API_KEY', nil),
      apikey: ENV.fetch('PORKBUN_API_KEY', nil)
    }.merge(options).to_json
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    JSON.parse(res.body, symbolize_names: true)
  end

  class Abstract
    attr_accessor :message, :status

    def success?
      @status == 'SUCCESS'
    end

    def parse_response(res)
      @message = res[:message]
      @status = res[:status]
    end
  end

  class Domain
    def self.list_all
      Porkbun.porkbun('domain/listAll')
    end
  end

  def self.ping
    porkbun 'ping'
  end

  def self.new(domain)
    Domain.new(domain)
  end

  class Record < Abstract
    attr_accessor :name, :content, :type, :ttl, :prio, :domain, :id, :notes

    def initialize(options)
      @name = options[:name]
      @content = options[:content]
      @type = options[:type]
      @ttl = options[:ttl] || 600
      @prio = options[:prio]
      @domain = options[:domain]
      @id = options[:id]
    end

    def self.create(options)
      record = Record.new options
      record.create
    end

    def edit
      raise Error, 'Need ID to id record' unless id

      res = Porkbun.porkbun File.join('dns/edit', domain, id), get_options
      parse_response res
      @id = res[:id]
      self
    end

    def save
      edit
    end

    def update(options = {})
      self.name = Record.relative_record_name(self)
      self.content = options[:content] if options.key?(:content)
      self.ttl = options[:ttl] if options.key?(:ttl)
      save
    end

    def self.list(domain, id = nil)
      raise Error, 'need domain' unless domain

      res = Porkbun.porkbun File.join('dns/retrieve', domain, id || '').chomp('/')
      return Error.new(res[:message]) if res[:status] == 'ERROR'

      res[:records].map do |record|
        Record.new record.merge(domain:)
      end
    end

    def self.domain_for(hostname)
      fqdn = hostname.to_s.chomp('.')
      domains = Porkbun::Domain.list_all[:domains].map { |item| item[:domain] }
      domains.sort_by(&:length).reverse.find do |domain|
        fqdn == domain || fqdn.end_with?(".#{domain}")
      end
    end

    def self.records_for(target, id = nil)
      requested = target.to_s.chomp('.')
      owner = domain_for(requested) || requested.split('.').last(2).join('.')
      records = list(owner, id)
      raise records if records.is_a?(Error)
      return records if owner == requested

      records.select { |record| record_hostname(record, owner) == requested }
    end

    def self.find_record(hostname)
      records = records_for(hostname)
      raise Error, 'No record found for hostname' if records.empty?
      raise Error, 'Multiple records found for hostname' if records.length > 1

      records.first
    end

    def self.create_record(record, options)
      fqdn = record.chomp('.')
      domain = domain_for(fqdn) || fqdn.split('.').last(2).join('.')
      name = fqdn == domain ? '' : fqdn.delete_suffix(".#{domain}")
      create(options.merge(domain:, name:))
    end

    def self.update_record(record, options)
      record.name = relative_record_name(record)
      record.content = options[:content] if options[:content]
      record.ttl = options[:ttl] if options[:ttl]
      record.save
      record
    end

    def self.delete_record(hostname)
      record = find_record(hostname)
      record.delete
      record
    end

    def self.delete_all(domain, id = '')
      list(domain, id).reject { |record| record.type == 'NS' }.each(&:delete)
    end

    def self.import_zone(file)
      record_regex = /^(?<hostname>[^\s]+)\.\s+(?<ttl>\d+)\s+IN\s+(?<type>[^\s]+)\s*(?<priority>\d+)?\s+(?<content>.+)$/
      IO.readlines(file).filter_map do |line|
        match_data = line.match(record_regex)
        next unless match_data

        labels = match_data[:hostname].split('.')
        options = {
          domain: labels[-2..].join('.'),
          name: labels[0..-3].join('.'),
          ttl: match_data[:ttl],
          type: match_data[:type],
          prio: match_data[:priority],
          content: match_data[:content].chomp('.').gsub(/^"|"$/, '')
        }.compact
        create(options)
      end
    end

    def self.public_ip
      Net::HTTP.get(URI('https://canhazip.com')).chomp
    end

    def self.update_dynamic(hostname, ip)
      records = records_for(hostname)
      return { created: true, record: create_record(hostname, type: 'A', content: ip) } if records.empty?

      record = records.first
      display = record.to_s
      update_record(record, content: ip)
      { created: false, display:, record: }
    end

    def self.record_hostname(record, domain)
      name = record.name.to_s.chomp('.')
      return domain if name.empty? || name == '@'

      name.end_with?(".#{domain}") ? name : "#{name}.#{domain}"
    end

    def self.relative_record_name(record)
      name = record.name.to_s.chomp('.')
      domain = record.domain.to_s.chomp('.')
      return '' if name == domain
      return name.delete_suffix(".#{domain}") if name.end_with?(".#{domain}")

      name
    end

    def delete
      raise Error, 'Need ID to delete record' unless id

      res = Porkbun.porkbun File.join('dns/delete', domain, id)
      parse_response res
      self
    end

    def to_s
      content_str = case type
                    when /TXT|SPF/
                      "\"#{content}\""
                    when /MX|CNAME|NS/
                      "#{content}."
                    else
                      String(content)
                    end

      prio_str = prio == '0' ? '' : prio
      "#{name}. #{ttl} IN #{type} #{prio_str} #{content_str}".tr_s(' ', ' ')
    end


    def to_h
      {
        name: name,
        content: content,
        type: type,
        ttl: ttl,
        prio: prio,
        domain: domain,
        id: id
      }
    end

    def create
      res = Porkbun.porkbun File.join('dns/create', domain), get_options
      parse_response res
      @id = res[:id]
      self
    end

    private

    def get_options
      options = {
        name:,
        content:,
        type:,
        ttl:
      }
      options.merge!(prio:) if prio and prio != '0'
      options
    end
  end


  class Domain
    attr_reader :domain

    def initialize(domain)
      @domain = domain.to_s.chomp('.')
    end

    def self.all
      list_all[:domains].map { |item| new(item[:domain]) }
    end

    def to_s
      domain
    end

    def records
      Record.list(domain)
    end

    def records_for(target)
      requested = normalize_hostname(target)
      records = Record.list(domain)
      raise records if records.is_a?(Error)
      return records if requested == domain

      records.select { |record| Record.record_hostname(record, domain) == requested }
    end

    def get_record(name)
      matches = records_for(name)
      raise Error, 'No record found for hostname' if matches.empty?
      raise Error, 'Multiple records found for hostname' if matches.length > 1

      matches.first
    end

    def create_record(name, options)
      hostname = normalize_hostname(name)
      relative_name = hostname == domain ? '' : hostname.delete_suffix(".#{domain}")
      Record.create(options.merge(domain:, name: relative_name))
    end


    def delete_all_records
      Record.delete_all(domain)
    end

    def zone_file
      records.map(&:to_s).join("\n") + "\n"
    end

    def self.get_record(hostname)
      Record.find_record(hostname)
    end


    def self.update_dynamic(hostname, ip)
      Record.update_dynamic(hostname, ip)
    end

    def update_dynamic(name, ip)
      matches = records_for(name)
      return { created: true, record: create_record(name, type: 'A', content: ip) } if matches.empty?

      record = get_record(name)
      display = record.to_s
      record.update(content: ip)
      { created: false, display:, record: }
    end

    private

    def normalize_hostname(name)
      hostname = name.to_s.chomp('.')
      return hostname if hostname == domain || hostname.end_with?(".#{domain}")

      "#{hostname}.#{domain}"
    end

    class << self
      def get_record(hostname)
        Record.find_record(hostname)
      end




      def create_record(hostname, options)
        Record.create_record(hostname, options)
      end


      def import(file)
        Record.import_zone(file)
      end

      def public_ip
        Record.public_ip
      end

      def update_dynamic(hostname, ip)
        Record.update_dynamic(hostname, ip)
      end
    end
  end
end
