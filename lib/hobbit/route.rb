module Hobbit
  # The route object. Manages parameter matching and compilation
  class Route
    attr_reader :block, :path

    def initialize(path, &block)
      @path, @block = path, block
      compile!
    end

    def param_placeholders
      @param_placeholders ||= []
    end

    def match(request_path_info)
      @last_match = @compiled_path.match(request_path_info)
    end

    def matched_parameters
      if @last_match
        @last_match.captures.each_with_index do |value, index|
          yield(value, @param_placeholders[index])
        end
      end
    end

    protected

    def compile!
      compiled_path = @path.gsub(/:\w+/) do |match|
        param_placeholders << match.gsub(':', '').to_sym
        '([^/?#]+)'
      end
      @compiled_path = /^#{compiled_path}$/
    end
  end
end