module RSQL
  OPTIONS = { :mode => 'column', :password => '', :user => ENV['USER'] }

  class RSQL < Object
    include Singleton
    
    class << self
      def execute(command)
        # split command into POSIX tokens
        if args = shellwords(command)
          # extract the actual command name
          method_name = args.shift
          # make sure there was a command
          unless method_name.nil?
            # if the command name corresponds to a method
            if instance.respond_to?(method_name)
              # invoke it
              instance.send(method_name, *args)
            else
              # otherwise, hand it off to ODBC
              instance.send :execute, command
            end
          end
        end
      rescue => error
        puts "ERROR: #{error}"
      end
    end

    private

    def initialize
      @dsn = nil
      @database = nil
    end

    def execute(command)
      unless @database.nil?
        begin
          @database.run(command) do |result|
            begin
              result.print
            rescue
              raise
            ensure
              result.drop
            end
          end
        rescue
          raise
        end
      else
        puts "No dsn selected"
      end
    end
    
    public

    def commit
      unless @database.nil?
        begin
          @database.commit
        rescue
          puts "ERROR: Commit failed"
          raise
        end
      else
        puts "No dsn selected"
      end
    end
    
    def describe(table, column = nil)
      unless @database.nil?
        begin
          if column
            statement = @database.columns(table, column)
          else
            statement = @database.columns(table)
          end
        rescue
          raise
        else
          begin
            statement.print :COLUMN_NAME => 'Field', :TYPE_NAME => 'Type', :COLUMN_SIZE => 'Size', :IS_NULLABLE => 'Null', :COLUMN_DEF => 'Default'
          rescue
            raise
          ensure
            statement.drop
          end
        end
      else
        puts "No dsn selected"
      end
    end
    
    def help
      puts "COMMIT"
      puts "DESCRIBE table"
      puts "HELP"
      puts "QUIT"
      puts "SET AUTOCOMMIT=value"
      puts "SHOW TABLES [LIKE pattern]"
      puts "USE dsn"
    end

    def quit
      exit
    end
  
    def set(expression)
      unless @database.nil?
        matches = /([a-z]*)=(.*)/.match(expression)
        if matches
          variable,value = matches[1,2]
          case variable.downcase
          when "autocommit"
            begin
              @database.autocommit = (1.coerce(value)[0] != 0)
            rescue ArgumentError
              raise(StandardError, "Variable '#{variable}' can't be set to the value of '#{value}'")
            else
              puts "autocommit set to #{@database.autocommit}"
            end
          else
            raise(StandardError, "Unknown system variable '#{variable}'")
          end
        else
          raise(StandardError, "Syntax error at '#{expression}'")
        end
      else
        puts "No dsn selected"
      end
    end
    
    def show(what, *args)
      unless @database.nil?
        case what.downcase
        when 'tables'
          source = @dsn
          begin
            if opt = args.shift
              if opt.downcase == 'like'
                if pattern = args.shift
                  statement = @database.tables(pattern)
                  source += " (#{pattern})"
                else
                  raise(StandardError, "Missing pattern after '#{opt}'")
                end
              else
                raise(StandardError, "Syntax error at '#{opt}'")
              end
            else
              statement = @database.tables
            end
          rescue
            raise
          else
            unless statement.nil?
              begin
                statement.print :TABLE_NAME => "Tables_in_#{source}"
              rescue
                raise
              ensure
                statement.drop
              end
            else
              puts "No tables to show"
            end
          end
        else
          raise(StandardError, "Syntax error at '#{what}'")
        end
      else
        puts "No dsn selected"
      end
    end
    
    def use(dsn)
      begin
        unless @database.nil?
          begin
            if @database.connected?
              # in case of pending transaction
              @database.rollback unless @database.autocommit
              @database.disconnect
            end
          rescue
          end
        end
        @dsn = dsn
        @database = ODBC.connect(@dsn, OPTIONS[:user], OPTIONS[:password])
      rescue
        puts "ERROR: Unable to connect to DSN '#{@dsn}' as user '#{OPTIONS[:user]}'"
        @database = nil
        @dsn = nil
        raise
      else
        puts "Database changed" unless OPTIONS[:quiet]
      end
    end
    
  end
end