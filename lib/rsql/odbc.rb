require 'fastercsv'

# extend ruby-odbc for printing result sets
module ODBC
  
  class Column
    def alias
      @alias ||= name
    end
    def alias=(value)
      @alias = value
    end
    def index
      @index ||= -1
    end
    def index=(value)
      @index = value
    end
    def width
      @width ||= self.alias.length
    end
    def width=(value)
      @width = value
    end
  end
  
  class Statement
    class << self
      def mode
        @mode ||= 'column'
      end
      
      def mode=(value)
        value = value.to_s
        Kernel.raise ArgumentError, "mode should be either 'column' or 'csv'" unless %w(column csv).include?(value)
        @mode = value
      end
    end
    
    def print(aliases = nil)
      # get the column names, etc.
      displayed_columns = columns(true)

      # set column indices
      displayed_columns.each_with_index do |c,i|
        c.index = i
      end

      # set column aliases (if provided)
      if aliases
        displayed_columns.collect! do |c|
          c if c.alias = aliases[c.name.to_sym]
        end.compact!
      end

      # fetch the data
      # TODO: handle huge result sets better... maybe paginate or base column width on initial n-record set
      resultset = fetch_all

      return 0 if resultset.nil? || resultset.empty?
      
      case self.class.mode
      when 'column'
        # determine the column widths (might be realy slow with large result sets)
        resultset.each do |r|
          displayed_columns.each do |c|
            if value = r[c.index]
              value = value.to_s
              c.width = value.length if value.length > c.width
            end
          end
        end

        # prepare the horizontal rule for header and footer
        rule = "+-" + displayed_columns.collect { |c| '-' * c.width }.join("-+-") + "-+"
        # output header
        puts rule
        puts "| " + displayed_columns.collect { |c| c.alias.ljust(c.width,' ') }.join(" | ") + " |"
        puts rule

        # output each row
        resultset.each do |r|
          puts "| " + displayed_columns.collect { |c| r[c.index].to_s.ljust(c.width, ' ') }.join(" | ") + " |"
        end

        # output footer
        puts rule
      when 'csv'
        # output header
        puts displayed_columns.collect { |c| c.alias }.to_csv(:force_quotes => true)
        # output each row
        resultset.each do |r|
          puts displayed_columns.collect { |c| r[c.index].to_s }.to_csv(:force_quotes => true)
        end
      end
      
      return resultset.size
    end
  end
  
  class TimeStamp
    def to_s
      "%04d-%02d-%02d %02d:%02d:%02d.%03u" % [ year, month, day, hour, minute, second, fraction ]
    end
  end
end
