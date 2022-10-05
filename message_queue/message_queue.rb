# A simple message queue that broadcasts published messages of a certain type to others listening to that type.
# NOTE: You don't need to change this module. Implement SimpleMessageQueue below.
module MessageQueue
  # Receiver will be called (with optional data) when an event of this type is received.
  # The method accepts one or more message types (either a string or an array of strings) followed by a block
  # NOTE: You can change method contract when you implement it
  def subscribe
    raise "implement!"
  end

  # Sends a notification to all registered listeners for the given type.
  # If a receiver acts badly, others should not be effected.
  def publish(type, data = nil)
    raise "implement!"
  end
end

# BEGIN CODE TO IMPLEMENT

# Implement this class
class SimpleMessageQueue
  include MessageQueue

  def initialize() 
    @receivers = []
  end

  ##
  # Creates a receiver object and subscribes it to messages of the provided type(s)
  # Takes in a block as a Proc, to be executed whenever a message of a subscribed type is received. 
  #
  def subscribe(types, &proc)
    if !types.respond_to?("each")
      types = [types]
    end

    receiver = {:proc => proc, :types => types}
    @receivers.push receiver
  end

  ##
  # Publishes a message by calling all blocks provided by 
  # receivers that subscribe to the provided type.
  #
  def publish(type, data = nil)
    @receivers.each do |receiver|
      if receiver[:types].include? type
        begin 
          receiver[:proc].call(data)
        rescue
          # do nothing, ensuring failures from blocks don't cause whole app to fail
        end
      end
    end
  end
end

# Extra credit!!! check out map_reduce.rb...

# END CODE TO IMPLEMENT
