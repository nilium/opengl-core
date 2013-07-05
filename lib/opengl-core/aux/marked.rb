module Gl ; end

class Gl::GlInternalMarked

  @@allocated__ = {}

  def ==(other)
    (self.kind_of?(other.class) || other.kind_of?(self.class)) && (self.name == other.name)
  end

  # Should be overridden by subclasses to handle freeing resources when marked.
  # If unmarked, should be a no-op.
  def delete
    __unmark__
    self
  end

  # Deletes all objects of the given type. Should be used carefully if at all.
  def self.delete_all
    __marked_allocated__.keys.each { |marked| marked.delete }
  end

  # Clears all marked objects. If deletion is already guaranteed for all marked
  # objects, you may use this to let all marked objects of this type get GC'd.
  def self.clear_all
    __marked_allocated__.clear
  end

  # @api private
  # Marks the class to prevent it from being garbage collected.
  def __mark__
    self.class.__marked_allocated__[self] = true
  end

  # @api private
  # Unmarks the class and allows it to be garbage collected.
  def __unmark__
    self.class.__marked_allocated__.delete(self)
  end

  # @api private
  # Returns whether the object is currently marked to keep it from being GC'd.
  def marked?
    self.class.__marked_allocated__.include?(self)
  end

  # @api private
  # Allocates a hash for the subclass. This will be done regardless of whether
  # this function is called.
  def self.inherited(subclass)
    @@allocated__[subclass] = @@allocated__[subclass] || {}
  end

  # @api private
  # Returns a Hash of marked objects.
  def self.__marked_allocated__
    (@@allocated__[self.class] || (@@allocated__[self.class] = {}))
  end

  # @api private
  # Returns all allocated marked objects for this class.
  def self.allocated
    __marked_allocated__.keys
  end

end
