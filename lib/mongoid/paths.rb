# encoding: utf-8
module Mongoid #:nodoc:
  module Paths #:nodoc:
    extend ActiveSupport::Concern
    included do
      attr_accessor :__path
      attr_accessor :_index
    end
    module InstanceMethods
      # Get the insertion modifier for the document. Will be nil on root
      # documents, $set on embeds_one, $push on embeds_many.
      #
      # Example:
      #
      # <tt>name.inserter</tt>
      def _inserter
        embedded? ? (_index ? "$push" : "$set") : nil
      end

      # Return the path to this +Document+ in JSON notation, used for atomic
      # updates via $set in MongoDB.
      #
      # Example:
      #
      # <tt>address.path # returns "addresses"</tt>
      def _path
        self.__path ||= lambda do
          embedded? ? "#{_parent._path}#{"." unless _parent._path.blank?}#{@association_name}" : ""
        end.call
      end

      # Returns the positional operator of this document for modification.
      #
      # Example:
      #
      # <tt>address.position</tt>
      def _position
        locator = _index ? (new_record? ? "" : ".#{_index}") : ""
        embedded? ? "#{_parent._position}#{"." unless _parent._position.blank?}#{@association_name}#{locator}" : ""
      end

      # Return the path to this +Document+ in JSON notation, used for atomic
      # updates via $set in MongoDB.
      #
      # Example:
      #
      # <tt>address.path # returns "addresses"</tt>
      def _pull
        _position.sub!(/\.\d+$/, '') || _position
      end

      # Get the removal modifier for the document. Will be nil on root
      # documents, $unset on embeds_one, $set on embeds_many.
      #
      # Example:
      #
      # <tt>name.remover</tt>
      def _remover
        embedded? ? (_index ? "$pull" : "$unset") : nil
      end

      # Return the selector for this document to be matched exactly for use
      # with MongoDB's $ operator.
      #
      # Example:
      #
      # <tt>address.selector</tt>
      def _selector
        embedded? ? _parent._selector.merge("#{_path}._id" => id) : { "_id" => id }
      end
    end
  end
end
