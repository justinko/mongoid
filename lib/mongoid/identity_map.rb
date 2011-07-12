# encoding: utf-8
module Mongoid #:nodoc:

  # Defines behaviour for the identity map in Mongoid.
  class IdentityMap < Hash

    # Mark the supplied criteria as being executed. This is so we don't return
    # partial results back for criteria that may have only some of it's
    # matching documents in the map.
    #
    # @example Mark the criteria as executed.
    #   identity_map.executed!(Person.where(:_id => id))
    #
    # @param [ Criteria ] criteria The criteria that has been executed.
    #
    # @since 2.1.0
    def executed!(criteria)
      executions << criteria.selector
    end

    # Has the provided criteria been executed? We don't want to return anything
    # from the map if it hasn't.
    #
    # @example Has the criteria been executed?
    #   identity_map.executed?(Person.all)
    #
    # @param [ Criteria ] criteria The criteria to check.
    #
    # @return [ true, false ] If the criteria has been executed.
    #
    # @since 2.1.0
    def executed?(criteria)
      executions.include?(criteria.selector)
    end

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
      if executed?(criteria)
        typed(criteria.klass).select do |doc|
          doc.matches?(criteria.selector)
        end
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

    # Get the criteria executions for the identity map or initialize it if
    # none.
    #
    # @example Get the executions.
    #   identity_map.executions
    #
    # @return [ Array<Hash> ] The executed criteria selectors.
    #
    # @since 2.1.0
    def executions
      self[:executions] ||= []
    end

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
      delegate \
        :clear,
        :executed!,
        :executed?,
        :get,
        :get_multi,
        :remove,
        :set,
        :to => :"Mongoid::Threaded.identity_map"
    end
  end
end
