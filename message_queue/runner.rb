#!/usr/bin/env ruby -w

# Do not modify this file.
# Run this script in order to see if your code is doing the right thing.

require './message_queue'
require '../test_support'

it "can publish something to nobody" do
  SimpleMessageQueue.new.publish "something"
end

it "can do simple pub / sub" do
  queue = SimpleMessageQueue.new
  last = nil
  queue.subscribe "foo" do |data|
    last = { :data => data }
  end

  queue.publish "foo", 42
  assert last[:data] == 42
end

it "gives the you values in order" do
  queue = SimpleMessageQueue.new
  values = []
  queue.subscribe "foo" do |data|
    values << data
  end

  queue.publish "foo", 1
  queue.publish "foo", 2
  queue.publish "foo", 3
  
  assert values === [1, 2, 3]
end

it "supports multiple event types" do
  queue = SimpleMessageQueue.new

  evens = 0
  odds = 0

  queue.subscribe "even" do |d|
    evens += 1
  end

  queue.subscribe "odd" do |d|
    odds += 1
  end

  [1, 2, 5, 6, 9, 14, 7].each do |i|
    type = i % 2 == 0 ? "even" : "odd"
    queue.publish type, i
  end

  assert evens == 3
  assert odds == 4
end

it "supports multiple receivers to the same event" do
  queue = SimpleMessageQueue.new

  n = 0

  queue.subscribe "number" do |i|
    n += i
  end

  queue.subscribe "number" do |i|
    n *= i
  end

  queue.publish "number", 5

  assert n == 25
end

it "should allow other receivers to process even if one fails" do
  queue = SimpleMessageQueue.new
  n = 0

  queue.subscribe "foo" do
    raise "i did something bad"
  end

  queue.subscribe "foo" do
    n += 1
  end

  3.times { queue.publish "foo" }
  assert n == 3
end

it "allows subscribing to multiple types on the same handler" do
  queue = SimpleMessageQueue.new
  
  a = []
  queue.subscribe ["number", "string"] do |data|
    a << data
  end

  queue.publish "number", 1
  queue.publish "string", "foo"
  queue.publish "number", 2
end

