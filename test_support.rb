# encoding: utf-8
# some very, very simple testing utilities

def colorize(text, color_code); "\e[#{color_code}m#{text}\e[0m";  end
def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end
def yellow(text); colorize(text, 33); end

def assert(condition)
  raise "fail!" unless condition
end

def it(name, &block)
  if block.nil?
    puts "\t#{yellow(name)}"
    return
  end

  begin
    yield
    puts """#{green("✓")}\t#{name}"""
  rescue Exception => e
    puts red("\t#{name}: #{e.message}")
  end
end
