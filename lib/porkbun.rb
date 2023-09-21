# frozen_string_literal: true

require 'http'
require_relative 'porkbun/version'

module Porkbun
  class Error < StandardError; end

  def self.porkbun(path, options = {})
    res = HTTP.post File.join('https://porkbun.com/api/json/v3', path), json: {
      secretapikey: ENV.fetch('PORKBUN_SECRET_API_KEY', nil),
      apikey: ENV.fetch('PORKBUN_API_KEY', nil)
    }.merge(options)

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

  class DNS < Abstract
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
      record = DNS.new options
      record.create
    end

    def edit
      raise Error, 'need id to edit' unless @id
    end

    def self.retrieve(domain, id = nil)
      raise Error, 'need domain' unless domain

      res = Porkbun.porkbun File.join('dns/retrieve', domain, id || '').chomp('/')
      return Error.new(res[:message]) if res[:status] == 'ERROR'

      res[:records].map do |record|
        DNS.new record.merge(domain:)
      end
    end

    def delete
      raise Error, 'Need ID to delete record' unless id

      res = Porkbun.porkbun File.join('dns/delete', domain, id)
      parse_response res
      self
    end

    require 'pry'
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

    def create
      options = {
        name:,
        content:,
        type:,
        ttl:
      }
      options.merge!(prio:) if prio
      res = Porkbun.porkbun File.join('dns/create', domain), options
      parse_response res
      @id = res[:id]
      self
    end
  end
end
