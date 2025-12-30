# Building

You *MUST* build in a Bash-like environment. Windows Git-bash does not appear to work. We can adjust this later, if needed.

1. Install Node.js, minimum version 20. The `nvm` toolset is useful for this. Ensure that `npm` and `npx` are on your execution path.

2. Create the folder `lib` and add `identityiq.jar` to it.

3. Execute `./gradlew` to build.

## Software versions required

* Node.js v20+
* Java 11, 17, or 21
* IdentityIQ 8.4+

The project's build uses Gradle 8.5 (via `gradlew` wrapper).

The Angular application builds with Angular v20.3.