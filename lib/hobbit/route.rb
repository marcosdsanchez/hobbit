module Hobbit
  # The route object. Manages parameter matching and compilation
  class Route
    attr_reader :block, :path

    def initialize(path, &block)
      @path, @block = path, block
      compile!
    end

    def names
      @names ||= []
    end

    def match(request_path_info)
      @last_match = @compiled_path.match(request_path_info)
    end

    def matched_parameters
      if @last_match
        matched_params = {}
        @last_match.captures.each_with_index do |value, index|
          yield(@names[index], value)
          matched_params[@names[index]] = value
        end
        matched_params
      end
    end

    protected

    def compile!
      compiled_path = @path.gsub(/:\w+/) do |match|
        names << match.gsub(':', '').to_sym
        '([^/?#]+)'
      end
      @compiled_path = /^#{compiled_path}$/
    end
  end
end
