FROM eclipse-temurin:21-jdk AS build

WORKDIR /app
COPY Main.java .
RUN javac Main.java

FROM eclipse-temurin:21-jre AS runtime

WORKDIR /app
COPY --from=build /app/Main.class .

EXPOSE 8080

ENTRYPOINT ["java", "Main"]
