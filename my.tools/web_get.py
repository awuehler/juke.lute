#!/usr/bin/env python3

'''
Description
    Script to quickly serve a directory of files on localhost. Python3
    http.server supports GET operations to download files from a
    directory (including sub directories).
    
    Use this script to enable URL access to a localhost folder of files
    for CLI or WEB access:
    
        e.g. "./web_get.py" (LNX only / Python v3)
        e.g. "python2"./web_get.py" (Python 2)
        e.g. "python web_get.py" (LNX and MSW environments)
        e.g. "ctrl-c" to exit...

Notes
    Usage for Microsoft Windows systems:

        -Run script to start an HTTP service in MSW PowerShell
         where this ought to get a route-able IP from whichever
         local sub directory
        
        -To use a WSL location use the following syntax (Ubuntu example):
         e.g. \\wsl.localhost\\Ubuntu\\home\\<USER_ID>\\...

Dependencies
    -Python v3.x is available within the localhost environment
    -All imported modules are available in localhost environment
    -The default HTTP port is available as defined in web_env.py
    -HTTP "GET" operations are allowed for files (FW and FS)
    -Using the route-able (public) IP assigned to the localhost

TODO:
    - Set an upper limit of number of files to display in console
'''

# ----------------------------------------------------------------------
# Module(s). Including a condition check of Python version and import.
# ----------------------------------------------------------------------
import os, socket, sys
from pathlib import Path

# Python version check.
if sys.version_info.major == 2:
    # Import Python v2 modules.
    import SimpleHTTPServer, SocketServer
elif sys.version_info.major == 3:
    # Import Python v3 modules.
    import http.server, socketserver
else:
    print( "ERROR: No Python environment detected...EXIT NOW!" )
    sys.exit( 1 )

# ----------------------------------------------------------------------
# Import environment and data file(s).
# ----------------------------------------------------------------------
import web_env

def host_ip_sock():
    # Capture public IP address for localhost.
    s = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )
    # NOTE: connect() for UDP doesn't send packets
    s.connect( ( '10.0.0.0', 0 ) ) 
    return s.getsockname()[0]

def walk_web_file():
    try:
        public_ip = host_ip_sock()
        http_url = "http://" + str( public_ip ) + ":" + web_env.LOCAL_PORT
        print( "HTTP URL:\t" + http_url + "/\n" )

        # Walk the CWD (location of script execution).
        for root, dirs, files in os.walk( ".", topdown=True ):
            for web_file in sorted( files ):
                for ext in web_env.target_extensions:
                    # Only include certain extensions (see web_env.py).
                    if web_file.lower().endswith( ext.lower() ):
                        # Re-confirm full path to file does exists.
                        if ( Path( os.path.join(root, web_file) ).exists() ):
                            # Only add unique entries to the list array.
                            if ( os.path.join(root, web_file) not in web_env.lotro_files ):
                                web_env.lotro_files.append( os.path.join(root, web_file) )

        # Print the sorted list of URLs for end user copy/paste operations.
        for i in web_env.lotro_files:
            i = i.replace( '\\', '/' )
            i = i.replace( '.', http_url, 1 )
            print( i )

    except:
        # For unknown problems.
        print( "WARNING: Check CWD file and directory ownership and/or permissions..." )
        sys.exit( 2 )

def warn_ip_address():
    Fetch_IP = host_ip_sock()
    Numerics = str( Fetch_IP ).split( "." )
    # Assumptions lurking here about exclusive use of an internal LAN 10. network.
    if int( Numerics[ 0 ] ) > 10:
        print( "WARNING:\tIP " + Fetch_IP + " likely non-routable (setup a bridge)!" )
    return

def main():
    try:
        # Setup object variables.
        HOST = web_env.LOCAL_HOST
        PORT = int( web_env.LOCAL_PORT )
        
        # Python version check to build correct handler.
        if sys.version_info.major == 2:
            # Use SimpleHTTPServer module for Python v2.
            HANDLER = SimpleHTTPServer.SimpleHTTPRequestHandler
            httpd   = SocketServer.TCPServer( ( HOST, PORT ), HANDLER )
        else:
            # Use http.server module for Python v3.
            HANDLER = http.server.SimpleHTTPRequestHandler
            httpd   = socketserver.TCPServer( ( HOST, PORT ), HANDLER )

        # Stdout for the user with fully qualified URLs for each discovered file.
        print( "\n-------------------------------------------------------------------------" )
        print( "SYSTEM IP:\t" + host_ip_sock() + " /" + " WEB SERVER PORT: " + str( PORT ) )
        warn_ip_address()
        walk_web_file()
        print( "\nTo Stop: Use CTRL-C key to exit from the HTTP server session\n" )
        print( "-------------------------------------------------------------------------\n" )
        
        # Initiate the HTTP web service until cancelled by user (ctrl-c).
        httpd.serve_forever()

    except KeyboardInterrupt:
        # Capture ctrl-c for proper exit.
        httpd.shutdown()
        sys.exit( 0 )

if __name__ == "__main__":
    """
        Setup to support both "shebang" and "import" code execution
        either as a script and/or imported into another module.
        Isolate all user defined file updates to this section.
    """
    # Runtime environment declarations.
    # See web_env.py
    
    # Main function to start simple HTTP service to serve a directory.
    main()
