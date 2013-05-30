require 'minitest_helper'

describe Hobbit::Route do
  before do
    @route = Hobbit::Route.new('/hi/:name') { puts request.params.to_s }
    @route_no_params = Hobbit::Route.new('/hi') { puts request.params.to_s }
  end

  describe '#initialize' do
    it 'must return an instance of Hobbit::Route' do
      @route.must_be_instance_of Hobbit::Route
    end

    it 'it must create an Array of param placeholders' do
      @route.param_placeholders.must_be_instance_of Array
    end

    context 'when the route has parameters' do
      it 'must return an Array with the name of the parameters' do
        @route.param_placeholders.wont_be_empty
      end
    end

    context 'when the route has no parameters' do
      it 'must return an empty Array' do
        @route_no_params.param_placeholders.must_be_empty
      end
    end
  end

  describe '#match' do
    context 'when the request_path_info matches the compiled path' do
      it 'must return a MatchData object' do
        @route.match('/hi/marcos').must_be_instance_of MatchData
      end
    end

    context 'when the request_path_info does not match the compiled path' do
      it 'must return nil' do
        @route.match('/hello/marcos').must_be_nil
      end
    end
  end

  describe '#matched_parameters' do
    context 'when the request path info matches the route params' do
      it 'must return an Array of matched parameters' do
        @route.match('/hi/marcos')
        params = @route.matched_parameters {}
        params.must_be_instance_of Array
        params.wont_be_nil
      end
    end

    context 'when the request path info doesn\'t match the route params' do
      it 'must return an empty Array of matched parameters' do
        @route.match('/hello/marcos')
        params = @route.matched_parameters {}
        params.must_be_nil
      end
    end
  end
end