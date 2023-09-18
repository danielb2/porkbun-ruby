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

    res.parse
  end

  class Domain
    def self.list_all
      Porkbun.porkbun('domain/listAll')
    end
  end

  def self.ping
    porkbun 'ping'
  end

  class DNS
    attr_accessor :name, :content, :type, :ttl, :prio, :service, :protocol, :port, :weight, :target

    def initialize(options)
      @name = options[:name]
      @content = options[:content]
      @type = options[:type]
      @ttl = options[:ttl]
      @prio = options[:prio]
      @id = options[:id]
    end

    def self.create(options)
      record = DNS.new options
      record.create
    end

    def edit
      raise Error, 'need id to edit' unless @id
    end

    def create(options)
      res = Porkbun.porkbun 'dns/create', {
        ttl: @ttl
      }.merge(options)
      @id = res['id']
      res
    end
  end
end
