FROM openjdk:17
COPY stagingjar/spring-boot-2-hello-world-1.0.jar hello-world.jar
ENTRYPOINT [ "java", "-jar", "hello-world.jar" ] 
