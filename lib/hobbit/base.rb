module Hobbit
  # Base class for all Hobbit applications and middleware.
  class Base
    class << self
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) do |path = '', &block|
          routes[verb] << settings[:route_class].new(path, &block)
        end
      end

      def map(path, &block)
        stack.map(path, &block)
      end

      alias_method :new!, :new
      def new(*args, &block)
        stack.run new!(*args, &block)
        stack
      end

      def routes
        @routes ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def settings
        @settings ||= {
            request_class: Rack::Request,
            response_class: Hobbit::Response,
            route_class: Hobbit::Route
        }
      end

      def stack
        @stack ||= Rack::Builder.new
      end

      def use(middleware, *args, &block)
        stack.use(middleware, *args, &block)
      end
    end

    attr_reader :env, :request, :response

    def settings
      self.class.settings
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      @request = settings[:request_class].new(@env)
      @response = settings[:response_class].new
      @route = match_route
      route_handler
    end

    private

    def match_route
      self.class.routes[@request.request_method].find do |route|
        route.match @request.path_info
      end
    end

    def route_handler
      if @route
        match_request_parameters
        @response.write instance_eval(&@route.block)
      else
        @response.status = 404
      end
      @response.finish
    end

    def match_request_parameters
      @route.matched_parameters do |route_param, request_value|
        @request.params[route_param] = request_value
      end
    end
  end
end
