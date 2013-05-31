require 'rack'

module Hobbit
  # The response object. See Rack::Response and Rack::Response::Helpers for
  # more info:
  # http://rack.rubyforge.org/doc/classes/Rack/Response.html
  # http://rack.rubyforge.org/doc/classes/Rack/Response/Helpers.html
  class Response < Rack::Response
    def initialize(*)
      header['Content-Type'] = 'text/html; charset=utf-8'
      super
    end
  end
end
