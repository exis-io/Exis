# Acceptance Tests

Acceptance tests verify the business value of features that we implement.  For
example, we claim that storing private user data is a feature supported by
Exis, and an acceptance test verifies that it works.

The initial definition of the acceptance test is written in prose, following
the Given-When-Then pattern.  A working example is shown below.

    Scenario: Updating private data
        Given I have an app named testapp
        Given testapp has an Auth appliance with level 1
        When alice updates user data
        Then alice can retrieve private user data

Lines starting with Given, When, or Then have corresponding Python functions
marked with decorators.  An example of a When step is below.  This example
also shows variable extraction from the string.

    @when("{user} updates user data")
    def step_impl(context, user):
        #
        # Python code to modify user private data
        #

If any step in the Scenario (Given, When, or Then) raises an Exception then
the test will be marked as failing.

## Getting Started

To run the tests, call "./test.sh".

The tests use the following directory structure.

features/ANY.feature       Feature definitions, one file per feature
features/environment.py    Place for special functions that run before/after events
features/steps/util.py     Utility functions, contains a function for making fabric calls
features/steps/ANY.py      Step definitions to implement the tests

Refer to the behave tutorial when writing tests:

    http://pythonhosted.org/behave/tutorial.html
