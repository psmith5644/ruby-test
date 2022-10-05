#!/usr/bin/env ruby -w

# custom tests

require './message_queue'
require '../test_support'

it "can do simple pub / sub" do
    queue = SimpleMessageQueue.new
    last = nil
    queue.subscribe 73 do |data|
      last = { :data => data }
    end
  
    queue.publish 73, 42
    assert last[:data] == 42
  end