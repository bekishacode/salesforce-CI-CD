@IsTest
private class GreeterTest {
    @IsTest
    static void greetsByName() {
        Assert.areEqual('Hello, Ada!', Greeter.greet('Ada'));
    }
    @IsTest
    static void greetsWorldWhenBlank() {
        Assert.areEqual('Hello, World!', Greeter.greet(' '));
    }
}
