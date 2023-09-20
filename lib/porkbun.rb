# frozen_string_literal: true

require 'http'
require_relative 'porkbun/version'

module Porkbun
  class Error < StandardError; end

  def self.porkbun(path, options = {})
    pp path
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

    def create
      res = Porkbun.porkbun File.join('dns/create', domain), {
        name:,
        content:,
        type:,
        ttl:
      }
      parse_response res
      @id = res[:id]
      self
    end
  end
end
