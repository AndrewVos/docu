module Docu
  class ObjectWithBinding
    def get_binding
      binding
    end
  end

  class ExecutesExamples
    def initialize kernel = Kernel
      @kernel = kernel
    end

    def execute path
      @kernel.puts "Executing Examples"
      errors = []
      successes = 0

      contents = File.read(path)

      contents.scan(/:example:((?:(?!^:end:).)*)/m).flatten.each do |example|
        current_binding = ObjectWithBinding.new.get_binding
        actual = nil

        example.lines.each do |line|
          if line =~ /#\s*=>\s*(.+)/
            expected = $1
            if actual == expected
              successes += 1
            else
              errors << "Assertion does not match example. Expected \"#{actual}\" to equal \"#{expected}\""
            end
          else
            actual = eval(line, current_binding).inspect
          end
        end
      end

      @kernel.puts "#{errors.size} example(s) failed, #{successes} example(s) passed"

      if errors.any?
        errors.each do |error|
          @kernel.puts error
        end
        @kernel.exit 1
      else
        File.open(path.chomp(File.extname(path)), "w") do |file|
          file.write contents.gsub(":example:\n", "").gsub(":end:\n", "")
        end
      end
    end
  end
end
