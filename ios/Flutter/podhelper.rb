# ios/Flutter/podhelper.rb
# 这个小文件只负责找到 Flutter SDK 并加载真正的 podhelper.rb

require 'json'

def read_flutter_root_from_generated_xcconfig
  generated = File.expand_path('Generated.xcconfig', __dir__)
  raise "Missing #{generated}. Run `flutter pub get` first." unless File.exist?(generated)

  File.foreach(generated) do |line|
    m = line.match(/FLUTTER_ROOT\s*=\s*(.*)/)
    return m[1].strip if m
  end
  raise 'FLUTTER_ROOT not found in Generated.xcconfig'
end

def flutter_root
  @flutter_root ||= read_flutter_root_from_generated_xcconfig
end

# 加载 Flutter SDK 里的真正实现
require File.expand_path(File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper.rb'))
