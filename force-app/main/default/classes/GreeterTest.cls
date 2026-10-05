@IsTest
private class GreeterTest {
    @IsTest
    static void greetsByName() {
        Assert.areEqual('Hi, Ada!', Greeter.greet('Ada'));
    }
    @IsTest
    static void greetsWorldWhenBlank() {
        Assert.areEqual('Hi, World!', Greeter.greet(' '));
    }
}
