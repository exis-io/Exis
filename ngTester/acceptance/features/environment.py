import time
from steps.utils import devs
TLD = "xs.demo"
deleteAppEndpoint = "{}.Appmanager/delete_app".format(TLD)
deleteAccountEndpoint = "{}.Auth/delete_domain".format(TLD)

def before_all(context):
    context.session = None


def before_scenario(context, scenario):
    context.raised = None
    devs.init(context)

def after_scenario(context, scenario):
    # Go through every developer used in test
    # Delete all their apps, then delete their account
    for dev in devs.getDevs(context):

        devSession = devs.getSession(context, dev)

        # We should remove all apps for the dev
        for appname in devs.getApps(context, dev):
            # All the users in app should leave
            for user in devs.getUsers(context, dev, appname):
                userSession = devs.getUserSession(context, dev, appname, user)
                userSession.leave()
            
            try:
                devSession.call(deleteAppEndpoint, appname, timeout=60)
            except Exception as error:
                pass

        fulldevdomain = "{}.{}".format(TLD, dev)

        # Call top level auth to remove their account
        try:
            devSession.call(deleteAccountEndpoint, fulldevdomain) 
        except Exception as error:
            pass

        devSession.leave()

    devs.init(context)
    time.sleep(1)



def after_all(context):
    if context.session:
        context.session.leave()
