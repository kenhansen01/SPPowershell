Import-Module SPConfigure
# Begin Testing
try
{
  InModuleScope -ModuleConnectionUrl SPConfigure -ScriptBlock {
    Function Set-ObjectMockProperties ($object,[switch]$Exists)
    {
      # This function will load the object and set the global script variables with the values supplied.
      # By doing this, we can later easily change how we interact with the object and make edits along
      # the way in other Mocks or Tests.
      New-VerboseMessage 'Establish Aggregate Mock variables and settings'
      [string]$script:___CurrentConnectionUrl = $object.ConnectionUrl
      [string[]]$script:___CurrentSPVersion   = $object.SPVersion
      [int]$script:___CurrentSiteSearchUrl    = $object.SiteSearchUrl
      if ($Exists) {$script:DeadmanObjectCreatedTrigger = $true;}
      else {$script:DeadmanObjectCreatedTrigger = $False;}

    }
    Function Set-MockModuleConfiguration
    {
      # This function will act as a Mock for our existing Set-SPModuleConfiguration function.  The benefit to this behavior is that
      # we can easily stub out the expected responses for the call.  We have included a Switch parameter call Empty
      # to allow us the ability to return either an item with default values (in the event that we want to test the output)
      # or an empty object to which we can assign any value.
      [CmdletBinding(supportsshouldprocess=$true)]
      Param([switch]$empty)
      $_mockConfig = [SPConfigure]::new() # The NEW() method is inherited by default for a class and does not need to be created.
      if ($empty)
      {
        # Since the empty parameter was sent, we will need to return just be new object with no data.
        
        return $_mockConfig;

      }
      else
      {
        $_mockConfig.ConnectionUrl = 'http://fake.sharepoint.site'
        $_mockConfig.SPVersion = 'Online'
        $_mockConfig.SiteSearchUrl = "/projects"

        return $_mockConfig;
      }
    }

    # This is a function of Mocks and makes life easier when we need to re-initialize Mocks between test suites.  The benefit to
    # to leveraging this function is seen when we have multiple suites that are not interdependent on each other.  Each test should
    # be treated as an independent state with no dependency on other tests.  This will ensure that the code that we test meets all
    # requirements and the correct behavior can be tested.
    Function Set-MockInstances ()
    {
      Mock Set-SPModuleConfiguration{
        New-VerboseMessage 'Mock Set-SPModuleConfiguration'
        if ($script:DeadmanObjectCreatedTrigger) {
          $ModuleConfig = Set-MockModuleConfiguration
          $ModuleConfig.ConnectionUrl = $___CurrentConnectionUrl
          $ModuleConfig.SPVersion     = $___CurrentSPVersion
          $ModuleConfig.SiteSearchUrl = $___CurrentSiteSearchUrl
          return $ModuleConfig
        } else {
          return (Set-MockModuleConfiguration -Empty)
        }
      }
    }

    # When testing large sections of code, it is always a good idea to distinguish messages from your test and any that may come from
    # your code.  This function will handle the way that we print out the code moving forward.
    Function New-VerboseMessage ($message)
    {
      $Classifier = '::PESTER:::::'
      # NOTE: Interpolation of strings is a common trick that I use with messages.  In this case, I have a message that I would like
      # to inject the value of two variables.  The '-f' identifies that these variables should be inserted into the string in and
      # translated to their position in the array that follows.  This allows me to easily make changes to the variables while maintaining
      # and easy to read command.  I typically use this technique in my large scripts, modules, and classes to streamline how I print the
      # the output.
      write-verbose -message ("{0}`t`t{1}" -f $Classifier, $Message)
    }

    #
    # This an Array of properties that exist in our object and will be referenced in other tests to ensure
    # all of the data is being returned from the Mocks.  This should be a list of ALL the properties in
    # the object scope.
    #
    $Test_Properties = @(
          'ConnectionUrl'
      ,   'SPVersion'
      ,   'SiteSearchUrl'
    )

    #
    # Establish both Passing and Failing Test Parameter Objects for using in the validation tests to streamline
    # the behavior of the tests.  Not setting a property will accept our defaults from the Mock
    $negativeTestParameters = @{
      ConnectionUrl           = 'http://fake.sharepoint.site'
      SPVersion               = 'Online'
      SiteSearchUrl           = $false
    }
    $positiveTestParameters = @{
      ConnectionUrl           = 'my new toy'
      SPVersion               = 'Playing'
      SiteSearchUrl           = $true
    }

    #
    # ModuleConfig::get() Validation Tests
    #
    Describe -ConnectionUrl 'ModuleConfig Get() Tests' -Tags @('ModuleConfig','ModuleConfigGet','Unit','Get') -Fixture {
      Set-MockInstances # Initiate the instances of Mock Servers and Environments for the suite
      Context 'When the Toy does not exist' {
        BeforeAll {
          # The BeforeAll will be triggered before each indiviual test to ensure that the data is
          # loaded and ready.  This gives us a clean slate opportunity between tests.
          Set-ObjectMockProperties -object $negativeTestParameters
        }

        # Since our method contains an overload for the ConnectionUrl property when searching, we are goung to create
        # a new instance of the ModuleConfig by calling our invoke function 'Set-SPModuleConfiguration' which ultimately leverages
        # our Mock and then initiate a call to GET() based on the ConnectionUrl property for our $negativeTestParameters
        # variable.  Since this item does not exist, it will return a $NULL ConnectionUrl and Online.
        $result = (Set-SPModuleConfiguration @negativeTestParameters).get($negativeTestParameters.ConnectionUrl)
        It 'Should return the ConnectionUrl as $Null and SPVersion as Online' {
          $result.ConnectionUrl | Should be $Null
          $result.SPVersion | Should Be 'Online'
        }
        It 'Should call the mock function Set-SPModuleConfiguration' {
          # Asserting a Mock is a great way to ensure that the behavior in this test matches the path that
          # we expect our code to take.  This is also a great way to capture inefficient code paths (Am I
          # making too many calls to the same function, Did I call something that I shouldn't, etc)
          #
          # If the code should NOT call a mock (For example, if we have a function that would be called on a Save), then
          # we can easily Asset that the Mock is called -Times 0.  This trick will help to ensure that we don't have a mistake
          # in the code pattern.
          Assert-MockCalled Set-SPModuleConfiguration -Exactly -Times 1 -Scope Context
        }
      }#context

      Context 'When the ToyExists' {
        BeforeAll {
          # We are testing the behvaior that the object should exist when called.  We can leverage this call and include our trigger
          # parameter -Exists to set the DeadmanObjectCreatedTrigger variable to $true.  This allows us to stub the output with a valid
          # object as if it was previously saved.
          Set-ObjectMockProperties -object $positiveTestParameters -Exists
        }

        # We have multiple tests that need to call on the same data.  In this case, we will return to the variable the object and use it
        # across the multiple tests.
        $result = (Set-SPModuleConfiguration @positiveTestParameters).get($positiveTestParameters.ConnectionUrl)
        It 'Should return the desired SPVersion as Stored' {
          $result.ConnectionUrl | Should Be 'my new toy'
          $result.SPVersion | Should Be 'Playing'
          $result.SiteSearchUrl | Should Be $True
        }

        It 'Should return the same values as passed as parameters' {
          # Previously we declared an array with all of our property ConnectionUrls.  We will now loop through this to ensure that we are returning
          # the correct values based on our expectations.  This because a very value test when we start changing values in later tests.
          Foreach ($t in ($Test_Properties| Where-object {$_}))
          {
            New-VerboseMessage ("Testing ($t) : $($result.$($t)) | Should Be $( $positiveTestParameters.$($t) )")
            $result.$($t) | Should Be $positiveTestParameters.$($t)
          }
        }

        It 'Should call the mock function Set-SPModuleConfiguration' {
          Assert-MockCalled Set-SPModuleConfiguration -Exactly -Times 1 -Scope Context
        }
        Assert-VerifiableMocks
      }#context

    }
  } #InModuleScope
} # try
finally
{
  # Done
} # finally