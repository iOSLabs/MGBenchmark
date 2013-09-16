class String
  def self.colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red
    self.class.colorize(self, 31)
  end

  def green
    self.class.colorize(self, 32)
  end
end

desc 'Run the tests'
task :build do
  buildAndLogScheme("")
  buildAndLogScheme("Example")
  buildAndLogScheme("Tests", true)
end

desc 'Report code coverage of main target to coveralls.io'
task :report do
  scheme = scheme_for_name("")
  settings = build_settings_per_target(workspace, scheme)[scheme]
  gcov_dir = "#{settings['OBJECT_FILE_DIR_normal']}/#{settings['CURRENT_ARCH']}"
  
  generate_gcov(gcov_dir)
  copy_gcov_to_project_dir(gcov_dir)
  send_report
  remove_gcov_dir
end

task :default => :build

def generate_gcov(gcov_dir)
  puts "generate gcov files..."
  command = "cd #{gcov_dir}"
  Dir["#{gcov_dir}/*.gcda"].each do |file|
    command << " && gcov-4.2 '#{file}' -o '#{gcov_dir}'"
  end
  `#{command}`
end

def copy_gcov_to_project_dir(gcov_dir)
  `cp -r '#{gcov_dir}' gcov`
end

def send_report
  puts "send report..."
  `coveralls -e 'Pods' --verbose`
end

def remove_gcov_dir
  `rm -r gcov`
end

def buildAndLogScheme(name, is_test = false)
  scheme = workspace.gsub(".xcworkspace", name)
  result = compile(workspace, scheme, is_test)
  log(scheme, result)
end

def scheme_for_name(name)
  workspace.gsub(".xcworkspace", name)
end

def workspace
  Dir["*.xcworkspace"].first
end

def log(scheme, result)
  scheme = "Default" if scheme == ""
  puts "#{scheme}: #{result == 0 ? 'PASSED'.green : 'FAILED'.red}"
end

def compile(workspace, scheme, is_test)
#  command = "xcodebuild -workspace #{workspace} -scheme #{scheme} -configuration Release -sdk iphonesimulator -verbose" 
#  command << " ONLY_ACTIVE_ARCH=NO TEST_AFTER_BUILD=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES" if is_test

  test = is_test ? "test" : ""
  command = "xctool #{test} -workspace #{workspace} -scheme #{scheme} -configuration Release -sdk iphonesimulator"
  command << " ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES" 

  IO.popen(command) do |io|
    while line = io.gets do
      puts line
      if line.index("** BUILD SUCCEEDED") == 0 or line.index("** TEST SUCCEEDED") == 0
        return 0
      elsif line.index("** BUILD FAIL") == 0
        return 1
      end
    end
  end
end

def build_settings_per_target(workspace, scheme)
  settings = `xctool -workspace #{workspace} -scheme #{scheme} -configuration Release -sdk iphonesimulator -showBuildSettings`
  current_target = ""
  result = {}
  settings.each_line do |line|
    if m = line.match(/^Build settings for action build and target (.+):/)
      current_target = m[1]
    elsif line.strip! == ""
      # skip
    elsif current_target
      parts = line.split(" = ")
      (result[current_target] ||= {})[parts[0]] = parts[1]
    end
  end
  result
end
