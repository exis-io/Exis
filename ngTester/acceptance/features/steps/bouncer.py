import time
from utils import devs

TLD = "xs.demo"

disableDevModeEndpoint = "{}.Bouncer/removeDevModeDomain".format(TLD)
addDynRoleEndpoint = "{}.Bouncer/addDynamicRole".format(TLD)
newDynRoleEndpoint = "{}.Bouncer/newDynamicRole".format(TLD)
revokeDynRoleEndpoint = "{}.Bouncer/revokeDynamicRole".format(TLD)
addSpecialAgentEndpoint = "{}.Bouncer/addSpecialAgent".format(TLD)
removeSpecialAgentEndpoint = "{}.Bouncer/removeSpecialAgent".format(TLD)
inDevModeEndpoint = "{}.Bouncer/inDevModeStatus".format(TLD)
listSpecAgentsEndpoint = "{}.Bouncer/listSpecialAgents".format(TLD)
listMembersEndpoint = "{}.Bouncer/listMembers".format(TLD)
addStaticRoleEndpoint = "{}.Bouncer/addStaticRole".format(TLD)
assignRoleEndpoint = "{}.Bouncer/assignRole".format(TLD)
revokeRoleEndpoint = "{}.Bouncer/revokeRole".format(TLD)
destroyRoleEndpoint = "{}.Bouncer/destroyRole".format(TLD)
setPermEndpoint = "{}.Bouncer/setPerm".format(TLD)
revokePermEndpoint = "{}.Bouncer/revokePerm".format(TLD)

def makeFullAppDomain(tld, dev, appname):
    return "{}.{}.{}".format(tld, dev, appname)

@given("{dev} disables dev mode in {appname}")
def step_impl(context, dev, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)

    devSession = devs.getSession(context, dev)

    result = devSession.call(disableDevModeEndpoint, fullappdomain)

    if result == False:
        raise Exception("Error disabling dev mode")


@given("{dev} creates a dynamic role {rolename} in {appname} with endpoints")
def step_impl(context, dev, rolename, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)

    perms = []
    if context.table:
        for row in context.table:
            perms.append({"target": "{}.{}".format(TLD, row[0]), "verb": "c"})

    devSession = devs.getSession(context, dev)
    result = devSession.call(addDynRoleEndpoint, rolename, fullappdomain, perms)

    if result == False:
        raise Exception("Error creating new dynamic role")


@given("{dev} assigns {assigndomain} to new dynamic role {rolename} instance in {appname}")
def step_impl(context, dev, assigndomain, rolename, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    # fullAssignDomain is the domain which we assign the role to
    # so this domain is the one which will have access to any endpoints defined
    #   in the dynamic role
    fullAssignDomain = "{}.{}".format(TLD, assigndomain)

    devSession = devs.getSession(context, dev)

    try:
        roleId = devSession.call(newDynRoleEndpoint, rolename,
                fullappdomain, [fullAssignDomain])
        # Set the role
        context.roleId = roleId
    except Exception:
        raise Exception("Error assigning new dynamic role")

@given("{dev} revokes {revokeDomain} from dynamic role {rolename} instance in {appname}")
def step_impl(context, dev, revokeDomain, rolename, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    fullRevokeDomain = "{}.{}".format(TLD, revokeDomain)

    devSession = devs.getSession(context, dev)

    # Revoke a domain from a specific role id
    if hasattr(context, 'roleId'):
        roleId = context.roleId
    else:
        raise Exception("No role id found")

    try:
        result = devSession.call(revokeDynRoleEndpoint, roleId, rolename,
                fullappdomain, [fullRevokeDomain])
    except Exception:
        raise Exception("Error revoking new dynamic role")

@given("{dev} creates a special agent {specialAgent} for {specialAgentDomain}")
def step_impl(context, dev, specialAgent, specialAgentDomain):

    # Special agent is the "agent" which can make calls in the special agent domain
    specialAgent = "{}.{}".format(TLD, specialAgent)
    specialAgentDomain = "{}.{}".format(TLD, specialAgentDomain)

    devSession = devs.getSession(context, dev)

    try:
        success = devSession.call(addSpecialAgentEndpoint, specialAgentDomain, specialAgent)
    except Exception as error:
        print(error)
        context.raised = error

@given("{dev} removes a special agent {specialAgent} for {specialAgentDomain}")
def step_impl(context, dev, specialAgent, specialAgentDomain):

    # Special agent is the "agent" which can make calls in the special agent domain
    specialAgent = "{}.{}".format(TLD, specialAgent)
    specialAgentDomain = "{}.{}".format(TLD, specialAgentDomain)

    devSession = devs.getSession(context, dev)

    try:
        success = devSession.call(removeSpecialAgentEndpoint,
                specialAgentDomain, specialAgent)
    except Exception as error:
        context.raised = error

@then("Bouncer says {dev} {appname} is in dev mode")
def step_impl(context, dev, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(inDevModeEndpoint, fullappdomain)
    if result == False:
        raise Exception("Bouncer should have reported that {}.{} is in dev mode".format(dev, appname))

@then("Bouncer says {dev} {appname} is NOT in dev mode")
def step_impl(context, dev, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(inDevModeEndpoint, fullappdomain)
    if result == True:
        raise Exception("Bouncer should have reported that {}.{} is NOT dev mode".format(dev, appname))

@then("Bouncer says {dev}.{appname} has no special agents")
def step_impl(context, dev, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(listSpecAgentsEndpoint, fullappdomain)
    if len(result) != 0:
        raise Exception("Bouncer should have reported that there are no special agents")

@then("Bouncer says {dev}.{appname} has special agents")
def step_impl(context, dev, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(listSpecAgentsEndpoint, fullappdomain)
    if len(result) == 0:
        raise Exception("Bouncer should have reported that there are special agents")

    # Only check the specific special agents if provided
    if context.table:
        for row in context.table:
            agent = "{}.{}".format(TLD, row[0])
            if agent not in result:
                raise Exception("Bouncer does not report that {} is a special agent.".format(agent))

@then("Bouncer says {dev}.{appname} role {rolename} has no members")
def step_impl(context, dev, appname, rolename):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(listMembersEndpoint, rolename, fullappdomain)
    if len(result) != 0:
        raise Exception("Bouncer should have reported that there are no members")


@then("Bouncer says {dev}.{appname} role {rolename} has members")
def step_impl(context, dev, appname, rolename):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(listMembersEndpoint, rolename, fullappdomain)
    if len(result) == 0:
        raise Exception("Bouncer should have reported that there are members")

    # Only check the specific special agents if provided
    if context.table:
        for row in context.table:
            agent = "{}.{}".format(TLD, row[0])
            if agent not in result:
                raise Exception("Bouncer does not report that {} is a member of role {}.".format(agent, rolename))

@given("{dev} creates a static role {rolename} in {appname} with endpoints")
def step_impl(context, dev, rolename, appname):

    devSession = devs.getSession(context, dev)
    fullappdomain = makeFullAppDomain(TLD, dev, appname)

    perms = []
    if context.table:
        for row in context.table:
            perms.append({"target": "{}.{}".format(TLD, row[0]), "verb": "c"})

    result = devSession.call(addStaticRoleEndpoint, rolename, fullappdomain, perms)

@given("{dev} assigns {assignDomain} to static role {rolename} in {appname}")
def step_impl(context, dev, assignDomain, rolename, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)
    assignDomain = "{}.{}".format(TLD, assignDomain)

    result = devSession.call(assignRoleEndpoint, rolename, fullappdomain, assignDomain)

@given("{dev} revokes {assignDomain} from static role {rolename} in {appname}")
def step_impl(context, dev, assignDomain, rolename, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)
    assignDomain = "{}.{}".format(TLD, assignDomain)


    result = devSession.call(revokeRoleEndpoint, rolename, fullappdomain, assignDomain)

@given("{dev} destroys static role {rolename} in {appname}")
def step_impl(context, dev, rolename, appname):

    fullappdomain = makeFullAppDomain(TLD, dev, appname)
    devSession = devs.getSession(context, dev)

    result = devSession.call(destroyRoleEndpoint, rolename, fullappdomain)

@given("{dev} gives {domain} access to single rules")
def step_impl(context, dev, domain):

    devSession = devs.getSession(context, dev)
    fullDomain = "{}.{}".format(TLD, domain)

    perms = []
    if context.table:
        for row in context.table:
            perm = "{}.{}".format(TLD, row[0])
            perms.append(perm)

    # For now, we assume that we are only doing call permissions
    verb = 'c'

    result = devSession.call(setPermEndpoint, fullDomain, perms, verb)

    # TODO check return value

@given("{dev} revokes {domain} access to single rules")
def step_impl(context, dev, domain):

    devSession = devs.getSession(context, dev)
    fullDomain = "{}.{}".format(TLD, domain)

    perms = []
    if context.table:
        for row in context.table:
            perm = "{}.{}".format(TLD, row[0])
            perms.append(perm)

    # For now, we assume that we are only doing call permissions
    # NOTE revoke doesn't currently revoke based on verb type? why?
    verb = 'c'

    result = devSession.call(revokePermEndpoint, fullDomain, perms)

    # TODO check return value
