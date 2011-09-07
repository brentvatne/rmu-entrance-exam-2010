module TextEditor
  class Document
    def initialize
      @contents = ""
      @changes  = []
      @undone_changes = []
    end
    
    attr_reader :contents

    def change(action, args)
      remember_change DocumentModification.new(action, args).execute(@contents)
    end
    
    def remember_change(this_change, action=:write)
      @undone_changes = [] unless action == :redo
      @changes << this_change
    end

    def add_text(text, position=@contents.length)
      change :add, { :text => text, :position => position }
    end

    def remove_text(first=0, last=contents.length)
      change :del, { :first => first, :last => last } 
    end
    
    def undo
      return if @changes.empty?
      @undone_changes << @changes.pop.reverse(@contents)
    end

    def redo
      return if @undone_changes.empty?
      remember_change(@undone_changes.pop.execute(@contents), :redo)
    end
  end

  class DocumentModification
    def initialize(action, args)
      @action = action
      @args = args
    end

    def execute(contents)
      case @action
      when :add
        contents.insert(@args[:position], @args[:text])
      when :del
        @deleted_text = contents.slice!(@args[:first]...@args[:last])
      end
      self
    end
    
    def reverse(contents)
      case @action
      when :add
        last_position = @args[:position] + @args[:text].length
        contents.slice!(@args[:position]...last_position)
      when :del
        contents.insert(@args[:first], @deleted_text)
      end
      self
    end
  end

end
