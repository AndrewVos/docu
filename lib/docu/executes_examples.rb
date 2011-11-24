module Docu
  class ExecutesExamples
    def initialize output, kernel = Kernel
      @output = output
      @kernel = kernel
    end

    def execute path
      @output.puts "Executing Examples"
      errors = []
      successes = 0

      contents = File.read(path)

      contents.scan(/:example:((?:(?!^:end:).)*)/m).flatten.each do |example|
        if example =~ /#\s*=>\s*(.+)/
          expected = $1
          actual = eval(example).inspect

          if actual == expected
            successes += 1
          else
            errors << "Assertion does not match example. Expected \"#{actual}\" to equal \"#{expected}\""
          end
        end
      end

      @output.puts "#{errors.size} example(s) failed, #{successes} example(s) passed"

      if errors.any?
        errors.each do |error|
          @output.puts error
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
