# encoding: utf-8
module Mongoid #:nodoc:

  # This module contains logic for easy access to objects that have a lifecycle
  # on the current thread.
  module Threaded
    extend self

    # Get the identity map off the current thread.
    #
    # @example Get the identity map.
    #   Threaded.identity_map
    #
    # @return [ IdentityMap ] The identity map.
    #
    # @since 2.1.0
    def identity_map
      Thread.current[:"[mongoid]:identity-map"] ||= IdentityMap.new
    end

    # Get the insert consumer from the current thread.
    #
    # @example Get the insert consumer.
    #   Threaded.insert
    #
    # @return [ Object ] The batch insert consumer.
    #
    # @since 2.1.0
    def insert
      Thread.current[:"[mongoid]:insert-consumer"]
    end

    # Set the insert consumer on the current thread.
    #
    # @example Set the insert consumer.
    #   Threaded.insert = consumer
    #
    # @param [ Object ] consumer The insert consumer.
    #
    # @return [ Object ] The insert consumer.
    #
    # @since 2.1.0
    def insert=(consumer)
      Thread.current[:"[mongoid]:insert-consumer"] = consumer
    end

    # Get the Mongoid scope stack or initialize it.
    #
    # @example Get the scope stack.
    #   Threaded.scope_stack
    #
    # @return [ Hash ] The current scope stack.
    #
    # @since 2.1.0
    def scope_stack
      Thread.current[:"[mongoid]:scope-stack"] ||= {}
    end

    # Get the update consumer from the current thread.
    #
    # @example Get the update consumer.
    #   Threaded.update
    #
    # @return [ Object ] The atomic update consumer.
    def update
      Thread.current[:"[mongoid]:update-consumer"]
    end

    # Set the update consumer on the current thread.
    #
    # @example Set the update consumer.
    #   Threaded.update = consumer
    #
    # @param [ Object ] consumer The update consumer.
    #
    # @return [ Object ] The update consumer.
    #
    # @since 2.1.0
    def update=(consumer)
      Thread.current[:"[mongoid]:update-consumer"] = consumer
    end
  end
end
