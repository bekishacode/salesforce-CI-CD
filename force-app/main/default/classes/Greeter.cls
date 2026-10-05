public with sharing class Greeter {
    public static String greet(String name) {
        return 'Hi, ' + (String.isBlank(name) ? 'World' : name) + '!';
    }
}
