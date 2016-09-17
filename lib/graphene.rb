#!/usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

require 'net/http'
require 'uri'
require 'json'

module Graphene
  class RPC
    @@rpc = nil

    def self.init(url = 'http://127.0.0.1:8090/rpc', username = nil, password = nil)
      @@rpc ||= Graphene::RPC.new(url, username, password)
    end
    def self.instance
      @@rpc || raise("Not initialized!")
    end

    def initialize(url, user, pass)
      @uri = URI(url)
      @req = Net::HTTP::Post.new(@uri)
      @req.content_type = 'application/json'
      @req.basic_auth user, pass if user
    end

    #def self.method_missing(name, *params)
    #  @@rpc.send(name, params)
    #end
    def method_missing(name, *params)
      request(name, params)
    end

    def request(method, params, id = 0)
      st = Time.now
      response = nil
      body     = {jsonrpc: "2.0", method: method, params: params, id: id}
      Net::HTTP.start(@uri.hostname, @uri.port) do |http|
        @req.body = body.to_json
        response  = http.request(@req)
      end
      result = JSON.parse(response.body)
      raise("called #{method}:#{params} -- #{result['error']}") if result['error']
      Rails.logger.info(" [GRAPHENE] #{method}(#{params.inspect}) rate: #{1 / (Time.now - st)}/s")
      result['result']
    end
  end
end
