"""
Issue calls into the Exis fabric.

Usage:
    exis [-djq] [--agent=DOMAIN] call <endpoint> [ARGS ...]
    exis [-djq] [--agent=DOMAIN] publish <endpoint> [ARGS ...]
    exis [-djq] [--agent=DOMAIN] register <endpoint>
    exis [-djq] [--agent=DOMAIN] subscribe <endpoint>

Options:
    -h --help       Show this information.
    -d --debug      Enable riffle debug output.
    -j --json       Format output as JSON.
    -q --quiet      Suppress output other than command results.
    --agent=DOMAIN  Domain to use on fabric (overrides the environment variable) [default: None]

Environment Variables:
    WS_URL          Websocket URL for node [default: ws://localhost:8000/ws]
    DOMAIN          Domain to use on fabric [default: xs]
    EXIS_KEY        Private key for authentication (path or PEM string) [default: None]
    EXIS_TOKEN      Token for authentication [default: None]
"""

from __future__ import print_function

import docopt
import json
import os
import time
import uuid
import yaml

from pprint import pprint

import riffle


def parseMessageArgs(args):
    """
    Separate a list of message arguments into positional and key-value groups.

    Returns a tuple.
    """
    pargs = list()
    kwargs = dict()
    for arg in args:
        parts = arg.split('=')
        if len(parts) == 1:
            obj = yaml.safe_load(parts[0])
            pargs.append(obj)
        else:
            obj = yaml.safe_load(parts[1])
            kwargs[parts[0]] = obj
    return (pargs, kwargs)


class ExisSession(riffle.Domain):
    def __init__(self, domain, args):
        super(ExisSession, self).__init__(domain)
        self.args = args

    def onJoin(self):
        endpoint = self.args['<endpoint>']
        pargs, kwargs = parseMessageArgs(self.args['ARGS'])

        if self.args['call']:
            start = time.time()
            result = self.call(endpoint, *pargs, **kwargs).wait(None)
            td = time.time() - start

            if not self.args['--quiet']:
                print("Return value:")
            if self.args['--json']:
                print(json.dumps(result))
            else:
                pprint(result)
            if not self.args['--quiet']:
                print("---")

            if not self.args['--quiet']:
                print("The call took {} seconds.".format(td))

            self.leave()

        elif self.args['publish']:
            start = time.time()
            result = self.publish(endpoint, *pargs, **kwargs).wait()
            td = time.time() - start

            if not self.args['--quiet']:
                print("The publish took {} seconds.".format(td))
            self.leave()

        elif self.args['register']:
            if "#details" not in endpoint:
                endpoint += "#details"
            raise NotImplemented()

        elif self.args['subscribe']:
            raise NotImplemented()


def parse_args(argv=None):
    args = docopt.docopt(__doc__, options_first=False)
    return args


def main():
    args = parse_args()

    ws_url = os.environ.get("WS_URL", "ws://localhost:8000/ws")
    domain = os.environ.get("DOMAIN", "xs")

    if args['--agent'] != "None":
        domain = args['--agent']

    if args['--debug']:
        riffle.SetLogLevelDebug()

    if not args['--quiet']:
        print("Node:   {}".format(ws_url))
        print("Domain: {}".format(domain))
        print("---")

    riffle.SetFabric(ws_url)
    ExisSession(domain, args).join()


if __name__ == "__main__":
    main()
