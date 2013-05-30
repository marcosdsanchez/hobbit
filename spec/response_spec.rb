require 'minitest_helper'

describe Hobbit::Response do
  describe '#initialize' do
    it 'must initialize Content-Type with text/html; charset=utf-8' do
      response = Hobbit::Response.new
      response.headers['Content-Type'].must_equal 'text/html; charset=utf-8'
    end
  end
end
