import ballerinax/java.jdbc;
import ballerina/config;

public function getConnection()  {

    jdbc:Client patientDB = new ({
        url: config:getAsString("URL");
        username: config:getAsString("USERNAME"),
        password: config:getAsString("PASSWORD"),
        poolOptions: { maximumPoolSize: 10 },
        dbOptions: { useSSL: false }
    });
}