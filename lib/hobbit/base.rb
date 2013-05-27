module Hobbit
  class Base
    class << self
      %w(DELETE GET HEAD OPTIONS PATCH POST PUT).each do |verb|
        define_method(verb.downcase) do |path = '', &block|
          routes[verb] <<  settings[:route_class].new(path, &block)
        end
      end

      def map(path, &block)
        stack.map(path, &block)
      end

      alias :new! :new
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

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      @request = self.class.settings[:request_class].new(@env)
      @response = self.class.settings[:response_class].new
      route_eval
      @response.finish
    end

    private

    def route_eval
      route = self.class.routes[request.request_method].detect { |r| r.compiled_path =~ request.path_info }
      if route
        $~.captures.each_with_index do |value, index|
          param = route.extra_params[index]
          request.params[param] = value
        end
        response.write instance_eval(&route.block)
      else
        response.status = 404
      end
    end
  end
end
