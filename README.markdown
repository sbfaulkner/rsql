# rsql

Command-line access to ODBC datasources.


## Installation

Run the following if you haven't already:

    $ gem sources -a http://gems.github.com
  
Install the gem(s):

    $ sudo gem install -r sbfaulkner-rsql

## Example

    $ rsql mydsn -u user -p password

    $ rsql mydsn -u user -p password -e 'select * from table'

## Legal

**Author:** S. Brent Faulkner <brentf@unwwwired.net>  
**License:** Copyright &copy; 2008 unwwwired.net, released under the MIT license
