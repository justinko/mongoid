# encoding: utf-8
module Mongoid #:nodoc:

  # Defines behaviour for the identity map in Mongoid.
  class IdentityMap < Hash

    # Get a document from the identity map by a criteria.
    #
    # @example Get a document by a criteria.
    #   identity_map.get(Person.where(:_id => id))
    #
    # @param [ Criteria ] criteria The criteria to use.
    #
    # @return [ Document ] The matching document.
    #
    # @since 2.1.0
    def get(criteria)
      typed(criteria.klass).detect do |doc|
        doc.matches?(criteria.selector)
      end
    end

    # Get documents from the identity map by a criteria.
    #
    # @example Get documents by a criteria.
    #   identity_map.get_multi(Person.where(:_id => id))
    #
    # @param [ Criteria ] criteria The criteria to use.
    #
    # @return [ Array<Document> ] The matching documents.
    #
    # @since 2.1.0
    def get_multi(criteria)
      typed(criteria.klass).select do |doc|
        doc.matches?(criteria.selector)
      end
    end

    # Remove a single document from the identity map.
    #
    # @example Remove the document from the map.
    #   identity_map.remove(document)
    #
    # @param [ Document ] document The document to remove.
    #
    # @return [ Document ] The removed document.
    #
    # @since 2.1.0
    def remove(document)
      return unless document
      typed(document.class).delete(document)
    end

    # Puts a document in the identity map, accessed by it's id.
    #
    # @example Put the document in the map.
    #   identity_map.set(document)
    #
    # @param [ Document ] document The document to place in the map.
    #
    # @return [ Array<Document> ] The documents for the class.
    #
    # @since 2.1.0
    def set(document)
      return unless document
      typed(document.class) << document
    end

    private

    # Get the documents grouped in the hash by the provided class, or
    # initialize an empty one.
    #
    # @example Get the grouped documents.
    #   identity_map.typed(Person)
    #
    # @param [ Class ] klass The model class.
    #
    # @return [ Array<Document ] The documents.
    #
    # @since 2.1.0
    def typed(klass)
      self[klass] ||= []
    end

    class << self

      # For ease of access we provide the same API to the identity map on the
      # class level, which in turn just gets the identity map that is on the
      # current thread.
      #
      # @example Get a document from the current identity map by id.
      #   IdentityMap.get(id)
      #
      # @example Get documents from the current identity map by ids.
      #   IdentityMap.get_multi([ id_one, id_two ])
      #
      # @example Set a document in the current identity map.
      #   IdentityMap.set(document)
      #
      # @example Set multiple documents in the identity map
      #   IdentityMap.set_multi([ doc_one, doc_two ])
      #
      # @since 2.1.0
      delegate :clear, :get, :get_multi, :remove, :set,
        :to => :"Mongoid::Threaded.identity_map"
    end
  end
end
