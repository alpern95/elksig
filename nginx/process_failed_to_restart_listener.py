#!/usr/bin/env python

import sys
from subprocess import call

def write_stdout(s):
    sys.stdout.write(s)
    sys.stdout.flush()

def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()

def kill_supervisord():
    with open('supervisord.pid', 'r') as f:
        pid = int(f.read())
        call(["kill", str(pid)])

def main():
    write_stdout('READY\n')
    headers_line = sys.stdin.readline()
    headers = dict([ x.split(':') for x in headers_line.split() ])
    body_line = sys.stdin.read(int(headers['len']))
    body = dict([ x.split(':') for x in body_line.split() ])
    write_stderr('\'%s\' process went in fatal state.\n Exiting the container...' % body['processname'])
    kill_supervisord()

if __name__ == '__main__':
    main()
