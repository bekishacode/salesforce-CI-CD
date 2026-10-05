public with sharing class Greeter {
    public static String greet(String name) {
        return 'Hello, ' + (String.isBlank(name) ? 'World' : name) + '!';
    }
}
