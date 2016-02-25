Feature: The app manager allows developers to create and modify apps.

    Appmanager is a core appliance that handles creating apps, adding
    appliances to apps, and deleting apps.
    TODO: check all limit functions (adding limits that are too large breaks)
    TODO: check starting/stopping containers works properly (need key in pyRiffle)
    TODO: add more testing to appliance templates

    Scenario: Finding appliances that can be added to an app
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Then Appmanager returns a nonempty list of appliances for dev1
    
    @test
    Scenario: Finding appliances templates that can be added to an app
        Given I have a developer named dev1
        Then Appmanager returns a nonempty list of appliance templates for dev1

    @test
    Scenario: Launch appname with uppercase letters should fail
        Given I have a developer named dev1
        Given dev1 has an app named Testapp
        Then it raises a runtime_error
        """
        Appname invalid: must consist of only lowercase chars and numbers (and begin with lowercase char)
        """
    
    @test
    Scenario: Can't create same app twice
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Given dev1 has an app named testapp
        Then it raises a runtime_error
        """
        App with same name already exists.
        """
    
    @test
    Scenario: Create, delete, create app works fine.
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Given dev1 removes an app named testapp
        Given dev1 has an app named testapp
        Then there is no error
    
    @test
    Scenario: Creating multiple apps works fine.
        Given I have a developer named dev1
        Given dev1 has an app named testapp1
        Given dev1 has an app named testapp2
        Then there is no error
    
    @test
    Scenario: Attaching an appliance to app that doesn't exist fails.
        Given I have a developer named dev1
        Given dev1.testapp has an appliance of type Storage
        Then it raises a runtime_error
        """
        App not found.
        """

    @test
    Scenario: Attaching a nonexistent appliance to app fails.
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Given dev1.testapp has an appliance of type BadAppliance
        Then it raises a runtime_error
        """
        Appliance name invalid.
        """
    
    @test
    Scenario: Attaching same appliance twice fails.
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Given dev1.testapp has an appliance of type Storage
        Given dev1.testapp has an appliance of type Storage
        Then it raises a runtime_error
        """
        Appliance already exists, call update/delete appliance.
        """

    @test
    Scenario: Dev does not have permission to stop their appliances.
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Given dev1.testapp has an appliance of type BadAppliance
        Then it raises a runtime_error
        """
        Appliance name invalid.
        """

    @test
    Scenario: Dev can add/remove the same appliance.
        Given I have a developer named dev1
        Given dev1 has an app named testapp
        Given dev1.testapp has an appliance of type Storage
        Given dev1.testapp removes an appliance of type Storage
        Given dev1.testapp has an appliance of type Storage
        Then there is no error
    
    @test1
    Scenario: Launching an app from template works.
        Given I have a developer named dev1
        Given dev1 has an app ionic from template ionic
        Then there is no error
