Gists
=====

    Usage: gists [ -h | --help ] <username>

Just scrape a user's gists of Github. Simple.


Output
------

Output is in the format of

    <gist url> <filename> <description> <snippet>


Example
-------

    lyndon@endpin ~ gists dhh | grep RAILS_ROOT
    https://gist.github.com/dhh/30007 gist:30007  def root ( * args ) if defined? ( RAILS_ROOT ) args . compact . empty? ? RAILS_ROOT : File . join ( RAILS_ROOT , args ) end end
