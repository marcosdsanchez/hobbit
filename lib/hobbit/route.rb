module Hobbit
  class Route
    attr_reader :block, :compiled_path, :path

    def initialize(path, &block)
      @path, @block = path, block
      compile
    end

    def compile
      @compiled_path = @path.gsub(/:\w+/) do |match|
        extra_params << match.gsub(':', '').to_sym
        '([^/?#]+)'
      end
      @compiled_path = /^#{@compiled_path}$/
    end

    def extra_params
      @extra_params ||= Array.new
    end
  end
end