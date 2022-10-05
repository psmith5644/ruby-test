#!/usr/bin/ruby -w

# Extra credit: Use the message queue you just built to create a map/reduce implementation
# Your implementation should be able to take a set of values, partition them, and calculation statistics on the partitions.


require './message_queue'
require '../test_support'


##
# This map/reduce implementation uses the message queue as the "shuffler" that 
# connects the output records from the map function to the reduce function.
#
# The +values+ input is partitioned into smaller arrays, and each partition is mapped.
# Currently there is only one machine doing the mapping, but each partition could be mapped concurrently 
# using multiple machines. The map functions creates messages (which are effectively key/value pairs) 
# which are published to the message_queue and consumed by the reduce functions, 
# which output their results to the results object.
# 
# If multiple machines were mapping their own partitions, they would all be able to publish to the same message queue,
# where their messages  would be consumed by the reduce functions.
#
def calculate_stats(values)
  q = SimpleMessageQueue.new
  # work your magic...
  results = { :even => { :sum => 0, :count => 0, :average => 0 }, :odd => { :sum => 0, :count => 0, :average => 0 } }

  # subscribe reducers to message queue
  reduceEven(q, results)
  reduceOdd(q, results)

  # partition the input and map each partition
  partitions = createPartitions(values)
  for partition in partitions do 
    map(partition, q)
  end

  return results
end

##
# Partitions the input values from +values+ into smaller arrays to be handled by the map function.
#
def createPartitions(values, partition_size = 100)
  partitions = []
  i = 0
  while i < values.length() do
    partitions.push(values[i, partition_size])
    i += partition_size
  end
  return partitions
end

##
# Maps the values in the +values_partition+ to key/value pairs,
# where the key is either "even" or "odd" and the value
# is the original numeric value.  Publishes those key/value pairs
# to the message queue.
#
def map(values_partition, queue)
  for value in values_partition do
    if value % 2 == 0
        queue.publish("even", value)
    else
        queue.publish("odd", value)
    end
  end
end

##
# The reduce function for even numbers.
# Reads messages from the message queue for the type/key "even."
# Manipulates and records data from the input to the +results+ object.
#
def reduceEven(queue, results)
  queue.subscribe "even" do |value|
      results[:even][:sum] += value
      results[:even][:count] += 1
      results[:even][:average] = results[:even][:sum] / results[:even][:count]
  end
end


##
# The reduce function for odd numbers.
# Reads messages from the message queue for the type/key "odd."
# Manipulates and records data from the input to the +results+ object. 
# 
def reduceOdd(queue, results)
  queue.subscribe "odd" do |value|
      results[:odd][:sum] += value
      results[:odd][:count] += 1
      results[:odd][:average] = results[:odd][:sum] / results[:odd][:count]
  end
end

values = [35, 59, 36, 59, 66, 17, 66, 5, 57, 15, 1, 27, 85, 52, 84, 57, 68, 64, 66, 46, 92, 13, 55, 78, 33, 46, 51, 12, 86, 25, 85, 19, 94, 44, 91, 68, 56, 89, 8, 39, 14, 90, 34, 56, 64, 83, 48, 94, 21, 88, 99, 85, 54, 18, 86, 64, 19, 53, 83, 70, 49, 0, 71, 7, 34, 43, 40, 97, 13, 0, 56, 78, 84, 36, 50, 30, 10, 89, 42, 76, 61, 55, 60, 18, 90, 13, 48, 88, 44, 70, 35, 11, 78, 20, 0, 20, 70, 96, 41, 18, 18, 52, 87, 81, 62, 55, 67, 42, 52, 42, 37, 14, 74, 15, 15, 68, 89, 51, 96, 74, 21, 86, 40, 34, 81, 10, 75, 59, 85, 91, 64, 1, 94, 85, 0, 83, 94, 19, 18, 60, 38, 8, 27, 24, 90, 3, 2, 1, 35, 7, 8, 48, 37, 9, 5, 46, 40, 5, 39, 7, 62, 58, 25, 62, 40, 56, 70, 96, 9, 57, 44, 11, 75, 97, 12, 50, 45, 49, 30, 16, 90, 78, 19, 50, 83, 70, 53, 23, 83, 65, 29, 98, 82, 39, 25, 13, 13, 25, 45, 1, 81, 44, 72, 74, 18, 66, 43, 34, 69, 90, 60, 51, 4, 43, 44, 86, 82, 63, 7, 33, 30, 17, 48, 3, 14, 87, 66, 30, 36, 53, 54, 55, 15, 10, 11, 35, 77, 9, 93, 15, 49, 62, 6, 34, 47, 81, 24, 57, 9, 56, 82, 75, 68, 93, 72, 36, 8, 57, 93, 10, 59, 42, 37, 58, 48, 94, 85, 5, 93, 68, 47, 41, 77, 75, 78, 55, 63, 58, 55, 18, 1, 5, 92, 46, 43, 82, 78, 29, 20, 74, 58, 98, 97, 44, 82, 51, 17, 43, 42, 8, 69, 53, 40, 10, 21, 20, 18, 77, 55, 44, 70, 23, 70, 64, 48, 25, 99, 7, 76, 62, 1, 75, 47, 98, 59, 57, 74, 40, 46, 21, 48, 13, 79, 31, 37, 65, 63, 68, 31, 64, 69, 22, 53, 75, 81, 97, 57, 83, 60, 78, 30, 20, 9, 65, 57, 82, 24, 19, 45, 43, 51, 9, 55, 85, 23, 70, 40, 94, 13, 5, 3, 52, 1, 5, 92, 0, 39, 85, 58, 8, 90, 56, 86, 59, 73, 75, 70, 89, 19, 28, 33, 18, 72, 48, 75, 40, 99, 42, 5, 88, 21, 7, 97, 56, 96, 69, 47, 89, 1, 27, 85, 45, 63, 57, 48, 63, 97, 70, 24, 2, 27, 21, 81, 17, 95, 58, 69, 85, 18, 6, 67, 43, 29, 89, 41, 80, 4, 86, 89, 10, 64, 19, 43, 59, 67, 20, 82, 44, 74, 16, 17, 5, 99, 39, 13, 66, 23, 56, 45, 79, 42, 67, 25, 91, 34, 15, 81, 19, 0, 48, 70, 70, 19, 48, 77, 57, 37, 85, 97, 12, 35, 96, 61, 22, 5, 34, 90, 69, 11, 19, 97, 55, 64, 96, 47, 71, 44, 59, 26, 83, 8, 0, 35, 21, 20, 2, 80, 46, 15, 53, 62, 80, 13, 70, 15, 55, 23, 21, 78, 95, 87, 56, 16, 16, 23, 82, 54, 10, 86, 96, 50, 85, 58, 37, 0, 24, 79, 86, 43, 34, 10, 46, 34, 21, 77, 50, 48, 53, 40, 21, 37, 39, 66, 89, 40, 54, 66, 82, 76, 34, 84, 85, 81, 32, 51, 30, 56, 31, 54, 44, 53, 74, 50, 35, 69, 26, 58, 22, 33, 35, 81, 75, 45, 31, 57, 93, 1, 90, 14, 53, 26, 5, 94, 59, 39, 52, 19, 39, 59, 65, 37, 77, 60, 64, 16, 80, 32, 12, 59, 76, 3, 89, 13, 81, 18, 66, 66, 25, 30, 54, 96, 19, 32, 37, 49, 2, 7, 38, 34, 87, 61, 22, 73, 57, 74, 50, 76, 29, 94, 41, 37, 35, 77, 63, 99, 63, 43, 2, 0, 30, 98, 44, 54, 1, 90, 14, 11, 39, 24, 90, 91, 79, 21, 70, 56, 43, 61, 61, 7, 52, 94, 73, 77, 76, 67, 4, 63, 3, 60, 2, 0, 79, 53, 89, 98, 40, 63, 0, 49, 98, 94, 83, 67, 1, 19, 73, 43, 68, 96, 29, 92, 11, 90, 88, 45, 9, 3, 65, 91, 96, 99, 75, 36, 83, 18, 79, 69, 14, 65, 4, 13, 73, 37, 51, 59, 22, 61, 93, 27, 90, 60, 16, 56, 58, 13, 86, 35, 51, 10, 64, 76, 52, 70, 15, 20, 65, 62, 99, 81, 53, 25, 47, 17, 23, 13, 68, 98, 52, 22, 54, 27, 95, 89, 55, 34, 0, 79, 38, 88, 53, 21, 24, 14, 77, 93, 0, 72, 26, 64, 45, 11, 98, 63, 37, 26, 40, 79, 5, 93, 81, 51, 24, 24, 35, 5, 85, 45, 2, 78, 32, 62, 3, 85, 28, 68, 94, 6, 36, 9, 4, 95, 47, 44, 12, 27, 14, 45, 95, 87, 17, 54, 57, 37, 85, 68, 55, 26, 32, 75, 50, 27, 35, 27, 42, 40, 65, 23, 54, 95, 90, 8, 62, 45, 17, 31, 81, 81, 32, 18, 16, 90, 66, 31, 26, 46, 91, 67, 21, 63, 74, 67, 26, 42, 35, 67, 4, 98, 80, 69, 99, 98, 68, 82, 11, 76, 76, 9, 72, 45, 90, 27, 68, 12, 22, 92, 7, 11, 79, 53, 30, 65, 89, 57, 32, 67, 6, 61, 87, 51, 75, 17, 56, 69, 21, 78, 95, 37, 60, 69, 81, 40, 69, 10, 25, 11, 37, 45, 11, 19, 64, 42, 44, 0, 50, 21, 52, 2, 31, 93, 94, 38, 39, 91, 70, 45, 97, 31, 90, 5, 31, 59, 48, 67, 3, 76, 52, 55, 11, 86, 26, 52, 42, 80, 51, 82, 65, 89, 72, 97, 21, 84, 31, 15, 67, 41, 59, 43, 39, 97, 80, 76, 31, 56, 32, 22, 84, 13, 97, 12, 76, 95, 53, 74, 63, 61, 57, 64, 74, 92, 87, 51, 17, 74, 98, 93, 81, 51, 2, 41, 30]
result = calculate_stats(values)
puts "Your answer: #{result.inspect}"
assert values.length == (result[:even][:count] + result[:odd][:count])
assert values.reduce(&:+) == (result[:even][:sum] + result[:odd][:sum])
