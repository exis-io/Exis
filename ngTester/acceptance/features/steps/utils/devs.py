"""
    This file has helper methods for accessing developer accounts, and their apps/etc
    These are manipulated through the context.devs attribute, which is a dict

    key: developer name
    value: dict

        key: apps
        value: dictionary of apps

            key: appname
            value: dictionary of appinfo
                
                key: users
                value: dictionary of users

                    key: username 
                    value: dictionary of user info

                        session: the users session
                        data: the users data??

                key: appliances
                value: dictionary of appliances

                    key: appliancename
                    value: dictionary of appliance options

        key: session
        value: the SyncSession used to make calls


"""
TLD = "xs.demo"

def init(context):
    context.devs = dict()

def addApp(context, dev, appname):
    context.devs[dev]['apps'][appname] = {'appliances': {}, 'users': {}}

def removeApp(context, dev, appname):
    context.devs[dev]['apps'][appname] = {'appliances': {}, 'users': {}}

def getApp(context, dev, appname):
    return context.devs[dev]['apps'][appname]

def addAppliance(context, dev, appname, appliance, applianceOptions):
    """
    Adds an appliance to the dictionary for this specific app in the specific dev's env
    """
    try:
        context.devs[dev]['apps'][appname]['appliances'][appliance] = applianceOptions
    except Exception as e:
        print("Error adding appliance: {}".format(e))

def removeAppliance(context, dev, appname, appliance):
    """
    Adds an appliance to the dictionary for this specific app in the specific dev's env
    """
    del context.devs[dev]['apps'][appname]['appliances'][appliance]

def getAppliances(context, dev, appname):
    return context.devs[dev]['apps'][appname]['appliances']

def addDev(context, dev, devsession=None):
    context.devs[dev] = { 
            'session': devsession,
            'apps': {}
    }

def addUser(context, dev, appname, user):
    context.devs[dev]['apps'][appname]['users'][user] = {
        "session": None,
        "data": {}
    }

def getUsers(context, dev, appname):
    return context.devs[dev]['apps'][appname]['users'].keys()


def setUserSession(context, dev, appname, user, session):
    context.devs[dev]['apps'][appname]['users'][user]['session'] = session

def getUserSession(context, dev, appname, user):
    return context.devs[dev]['apps'][appname]['users'][user]['session']

def getAuthLevel(context, dev, appname):
    return context.devs[dev]['apps'][appname]['appliances']['Auth']['authLevel']

def getSession(context, dev):
    return context.devs[dev]['session']

def setSession(context, dev, session):
    context.devs[dev]['session'] = session

def getDevs(context):
    return context.devs.keys()

def getApps(context, dev):
    return context.devs[dev]['apps'].keys()
